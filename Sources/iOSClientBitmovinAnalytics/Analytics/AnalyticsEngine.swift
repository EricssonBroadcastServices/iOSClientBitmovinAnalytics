// SPDX-FileCopyrightText: 2026 Red Bee Media Ltd <https://www.redbeemedia.com/\>
//
// SPDX-License-Identifier: MIT

import Foundation

protocol AnalyticsEngineProtocol {
    var configuration: AnalyticsConfiguration { get }
    func start() async
    func trackEvent(_ event: AnalyticsEvent, additionalPayload: AnalyticsPayloadProtocol?) async
    func trackTimeChangedEvent(additionalPayload: AnalyticsPayloadProtocol?) async
}

extension AnalyticsEngineProtocol {
    func track(_ event: AnalyticsEvent) {
        Task {
            await trackEvent(event, additionalPayload: nil)
        }
    }

    func track(_ event: AnalyticsEvent, additionalPayload: AnalyticsPayloadProtocol?) {
        Task {
            await trackEvent(event, additionalPayload: additionalPayload)
        }
    }
}

enum AnalyticsEngineError: Error {
    case incorrectURL
    case receivedTimeIsNil
}

actor AnalyticsEngine: AnalyticsEngineProtocol {
    let configuration: AnalyticsConfiguration

    private let session: URLSession
    private var flushTask: Task<Void, Never>?
    private var eventsPayloads = [[String: Any]]()
    private var latestTimeChangedPayload: [String: Any]?
    private let syncInterval: TimeInterval = 60 * 30 // 30 minutes
    private var synchronizedClockOffset: Int64?
    private let timeChangedPayloadKey = "TimeChangedPayloadKey"

    private let networkClient: any NetworkClientProtocol
    private let eventsStorage: (any DiskStorageProtocol)?
    private let timeChangedStorage: (any DiskStorageProtocol)?

    init(
        configuration: AnalyticsConfiguration,
        session: URLSession = .shared,
        networkClient: some NetworkClientProtocol = NetworkClient(),
        eventsStorage: (some DiskStorageProtocol)? = DiskStorage(
            folderNameSuffix: "EventsPayloads",
            maxStoredFiles: 1000
        ),
        timeChangedStorage: (some DiskStorageProtocol)? = DiskStorage(
            folderNameSuffix: "TimeChangedPayload",
            maxStoredFiles: 1
        )
    ) {
        self.configuration = configuration
        self.session = session
        self.networkClient = networkClient
        self.eventsStorage = eventsStorage
        self.timeChangedStorage = timeChangedStorage
    }

    func start() async {
        if let savedPayloads = eventsStorage?.readAllPayloads() {
            eventsPayloads = savedPayloads
        }
        if let savedTimeChangedPayload = timeChangedStorage?.readPayload(for: timeChangedPayloadKey) {
            latestTimeChangedPayload = savedTimeChangedPayload
        }
        await synchronize()
        Task { [weak self] in
            await self?.startSyncLoop()
        }
        Task { [weak self] in
            await self?.startFlushLoop()
        }
    }

    func trackEvent(_ event: AnalyticsEvent, additionalPayload: AnalyticsPayloadProtocol? = nil) async {
        var payload: [String: Any] = [
            AnalyticsKeys.eventType: event.rawValue,
            AnalyticsKeys.timestamp: Int(Date().timeIntervalSince1970),
            AnalyticsKeys.playerTechnology: "Bitmovin",
        ]
        additionalPayload?.asDictionary
            .compactMapValuesRecursively()
            .forEach { payload[$0] = $1 }
        eventsPayloads.append(payload)
        if event != .deviceInfo {
            eventsStorage?.writePayload(payload)
        }
        logInfo("\(event.rawValue) event queued")
    }

    func trackTimeChangedEvent(additionalPayload: AnalyticsPayloadProtocol? = nil) async {
        var timeChangedPayload: [String: Any] = [
            AnalyticsKeys.eventType: AnalyticsEvent.timeChanged.rawValue,
            AnalyticsKeys.timestamp: Int(Date().timeIntervalSince1970)
        ]
        additionalPayload?.asDictionary
            .compactMapValuesRecursively()
            .forEach { timeChangedPayload[$0] = $1 }
        latestTimeChangedPayload = timeChangedPayload
        timeChangedStorage?.writePayload(timeChangedPayload, key: timeChangedPayloadKey)
    }

    private func startSyncLoop() async {
        while !Task.isCancelled {
            try? await Task.sleep(seconds: syncInterval)
            await self.synchronize()
        }
    }

    private func startFlushLoop() async {
        while !Task.isCancelled {
            try? await Task.sleep(seconds: TimeInterval(configuration.postInterval))
            await self.sendEvents()
        }
    }

    private func synchronize() async {
        do {
            synchronizedClockOffset = try await getSynchronizedClockOffset()
            logInfo("Synchronized clock offset = \(synchronizedClockOffset)")
        } catch {
            logError("Failed to synchronize clock offset", error: error)
        }
    }

    private func getSynchronizedClockOffset() async throws -> Int64 {
        let clientStart = Date().millisecondsSince1970
        let analyticsRemoteConfig = try await getAnalyticsRemoteConfig()

        guard
            let receivedTime = analyticsRemoteConfig.receivedTime,
            let repliedTime = analyticsRemoteConfig.repliedTime
        else {
            logError("Failed to get SynchronizedClockOffset, receivedTime or repliedTime is nil")
            throw AnalyticsEngineError.receivedTimeIsNil
        }

        let clientEnd = Date().millisecondsSince1970
        return (clientEnd - repliedTime + clientStart - receivedTime) / 2
    }

    private func getAnalyticsRemoteConfig() async throws -> AnalyticsInitializationResponse {
        guard let url = URL(string: "\(configuration.baseURL)/eventsink/init") else {
            logError("Invalid URL for analytics remote config")
            throw AnalyticsEngineError.incorrectURL
        }
        return try await networkClient.performRequest(url: url, method: .post, headers: [:], body: nil)
    }

    private func sendEvents() async {
        let payloadSource = getPayloadSource()

        guard !payloadSource.isEmpty else {
            return
        }

        var body: [String: Any] = [
            "BusinessUnit": configuration.businessUnit,
            "Customer": configuration.customer,
            "DispatchTime": Int(Date().timeIntervalSince1970),
            "Payload": payloadSource.value,
            "SessionId": configuration.sessionID
        ]
        if let clockOffset = synchronizedClockOffset {
            body["ClockOffset"] = clockOffset
        }

        let jsonData: Data
        do {
            jsonData = try JSONSerialization.data(withJSONObject: body)
        } catch {
            logError("Failed to serialize events payload to JSON", error: error)
            return
        }

        guard let url = URL(string: "\(configuration.baseURL)/eventsink/send") else {
            logError("Invalid URL for sending events")
            return
        }
        var headers = [
            "Authorization": "Bearer " + configuration.sessionToken,
            "Content-Type": "application/json"
        ]

        if let requestID = configuration.requestID {
            headers["X-Request-Id"] = requestID
        }

        do {
            try await networkClient.performRequest(
                url: url,
                method: .post,
                headers: headers,
                body: jsonData
            )
            logInfo("Events sent succesfully, events count: \(payloadSource.value.count)")
            clearSentPayloads(for: payloadSource)
        } catch {
            guard
                let networkError = error as? NetworkError,
                networkError.isRetryable
            else {
                logError("Send events request failed and events were discarded", error: error)
                clearSentPayloads(for: payloadSource)
                return
            }
            logError("Send events request failed with retryable error, events were not removed", error: error)
        }
    }

    private func getPayloadSource() -> AnalyticsPayloadSource {
        if !eventsPayloads.isEmpty {
            return .events(eventsPayloads)
        } else if let latestTimeChangedPayload {
            return .timeChanged(latestTimeChangedPayload)
        } else {
            return .none
        }
    }

    private func clearSentPayloads(for payloadSource: AnalyticsPayloadSource) {
        switch payloadSource {
        case .events:
            eventsPayloads = []
            eventsStorage?.clear()
            logInfo("Removed stored event payloads")
        case .timeChanged:
            latestTimeChangedPayload = nil
            timeChangedStorage?.clear()
            logInfo("Removed stored TimeChangedEvent payload")
        case .none:
            break
        }
    }
}
