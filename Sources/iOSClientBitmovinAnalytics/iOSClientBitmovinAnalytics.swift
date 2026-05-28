// SPDX-FileCopyrightText: 2026 Red Bee Media Ltd <https://www.redbeemedia.com/\>
//
// SPDX-License-Identifier: MIT

import BitmovinPlayer
import Combine

/// Adapter for Bitmovin analytics integration.
public final class BitmovinAnalyticsAdapter {
    private weak var player: BitmovinPlayer.Player?
    private let analytics: any AnalyticsEngineProtocol
    private let connectionTypeMonitor: any ConnectionTypeMonitorProtocol

    private var cancellables = Set<AnyCancellable>()

    /// Creates an adapter that integrates analytics configuration with the player analytics pipeline.
    ///
    /// - Parameter configuration: Analytics configuration used to initialize the adapter.
    public init(configuration: AnalyticsConfiguration) {
        self.analytics = AnalyticsEngine(configuration: configuration)
        self.connectionTypeMonitor = ConnectionTypeMonitor()
    }

    init(
        analytics: some AnalyticsEngineProtocol,
        connectionTypeMonitor: some ConnectionTypeMonitorProtocol
    ) {
        self.analytics = analytics
        self.connectionTypeMonitor = connectionTypeMonitor
    }

    /// Reports that the current program has changed.
    public func trackProgramChanged() {
        analytics.track(.programChanged)
    }

    func attach(to player: BitmovinPlayer.Player) {
        guard self.player == nil else { return }

        self.player = player
        Task { [weak self] in
            await self?.analytics.start()
            self?.analytics.track(.deviceInfo, additionalPayload: self?.deviceInfoPayload)
            self?.attachListeners()
        }
    }

    private func attachListeners() {
        guard let player else {
            Swift.assert(false, "BitmovinAnalyticsAdapter.attachListeners() called but player is nil")
            return
        }

        player.events
            .on(AdBreakFinishedEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.adBreakFinished)
            }
            .store(in: &cancellables)

        player.events
            .on(PlayEvent.self)
            .sink { [weak self, player] _ in
                let payload = PlaybackPositionPayload(playbackPosition: player.currentTime)
                self?.analytics.track(.play, additionalPayload: payload)
            }
            .store(in: &cancellables)

        player.events
            .on(AdBreakStartedEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.adBreakStarted)
            }
            .store(in: &cancellables)

        player.events
            .on(AdErrorEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.adError)
            }
            .store(in: &cancellables)

        player.events
            .on(AdFinishedEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.adFinished)
            }
            .store(in: &cancellables)

        player.events
            .on(AdSkippedEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.adSkipped)
            }
            .store(in: &cancellables)

        player.events
            .on(AdStartedEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.adStarted)
            }
            .store(in: &cancellables)

        player.events
            .on(AirPlayChangedEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.airplayChanged)
            }
            .store(in: &cancellables)

        player.events
            .on(AudioChangedEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.audioChanged)
            }
            .store(in: &cancellables)

        player.events
            .on(CastStartEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.castStart)
            }
            .store(in: &cancellables)

        player.events
            .on(CastStartedEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.castStarted)
            }
            .store(in: &cancellables)

        player.events
            .on(CastStoppedEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.castStopped)
            }
            .store(in: &cancellables)

        player.events
            .on(DvrWindowExceededEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.dvrWindowExceeded)
            }
            .store(in: &cancellables)

        player.events
            .on(DestroyEvent.self)
            .sink { [weak self, player] _ in
                let payload = PlaybackPositionPayload(playbackPosition: player.currentTime)
                self?.analytics.track(.destroy, additionalPayload: payload)
            }
            .store(in: &cancellables)

        player.events
            .on(DurationChangedEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.durationChanged)
            }
            .store(in: &cancellables)

        player.events
            .on(PlayerErrorEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.playerError)
            }
            .store(in: &cancellables)

        player.events
            .on(MutedEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.muted)
            }
            .store(in: &cancellables)

        player.events
            .on(PausedEvent.self)
            .sink { [weak self, player] _ in
                let payload = PlaybackPositionPayload(playbackPosition: player.currentTime)
                self?.analytics.track(.paused, additionalPayload: payload)
            }
            .store(in: &cancellables)

        player.events
            .on(PlaybackFinishedEvent.self)
            .sink { [weak self, player] _ in
                let payload = PlaybackPositionPayload(playbackPosition: player.currentTime)
                self?.analytics.track(.playbackFinished, additionalPayload: payload)
            }
            .store(in: &cancellables)

        player.events
            .on(PlaybackSpeedChangedEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.playbackSpeedChanged)
            }
            .store(in: &cancellables)

        player.events
            .on(PlayingEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.playing)
            }
            .store(in: &cancellables)

        player.events
            .on(ReadyEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.ready)
            }
            .store(in: &cancellables)

        player.events
            .on(SeekEvent.self)
            .sink { [weak self, player] _ in
                let payload = PlaybackPositionPayload(playbackPosition: player.currentTime)
                self?.analytics.track(.seek, additionalPayload: payload)
            }
            .store(in: &cancellables)

        player.events
            .on(SeekedEvent.self)
            .sink { [weak self, player] _ in
                let payload = PlaybackPositionPayload(playbackPosition: player.currentTime)
                self?.analytics.track(.seeked, additionalPayload: payload)
            }
            .store(in: &cancellables)

        player.events
            .on(SourceLoadedEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.sourceLoaded)
            }
            .store(in: &cancellables)

        player.events
            .on(StallEndedEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.stallEnded)
            }
            .store(in: &cancellables)

        player.events
            .on(StallStartedEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.stallStarted)
            }
            .store(in: &cancellables)

        player.events
            .on(SubtitleChangedEvent.self)
            .sink { [weak self] track in
                switch track.subtitleTrackNew {
                case .some:
                    self?.analytics.track(.subtitleEnabled)
                case .none:
                    self?.analytics.track(.subtitleDisabled)
                }
            }
            .store(in: &cancellables)

        player.events
            .on(TimeChangedEvent.self)
            .sink { [weak self, player] _ in
                let payload = PlaybackPositionPayload(playbackPosition: player.currentTime)
                Task {
                    await self?.analytics.trackTimeChangedEvent(additionalPayload: payload)
                }
            }
            .store(in: &cancellables)

        player.events
            .on(TimeShiftedEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.timeShifted)
            }
            .store(in: &cancellables)

        player.events
            .on(UnmutedEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.unmuted)
            }
            .store(in: &cancellables)

        player.events
            .on(VideoPlaybackQualityChangedEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.videoPlaybackQualityChanged)
            }
            .store(in: &cancellables)

        player.events
            .on(PlayerWarningEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.warning)
            }
            .store(in: &cancellables)

        player.events
            .on(FairplayLicenseAcquiredEvent.self)
            .sink { [weak self] _ in
                self?.analytics.track(.drmLicenseAdded)
            }
            .store(in: &cancellables)

        AppLifecyclePublisher.publisher
            .sink { [weak self] event in
                switch event {
                case .resumed:
                    self?.analytics.track(.appResumed)
                case .backgrounded:
                    self?.analytics.track(.appBackgrounded)
                }
            }
            .store(in: &cancellables)

        connectionTypeMonitor.connectionTypePublisher
            .dropFirst()
            .sink { [weak self] connectionType in
                self?.analytics.track(
                    .connectionTypeChange,
                    additionalPayload: ConnectionTypeChangePayload(connectionType: connectionType.rawValue)
                )
            }
            .store(in: &cancellables)
    }
}

// MARK: - deviceInfoPayload
extension BitmovinAnalyticsAdapter {
    private var deviceInfoPayload: DeviceInfoPayload {
        DeviceInfoPayload(
            height: Int(UIScreen.main.bounds.height),
            width: Int(UIScreen.main.bounds.width),
            name: UIDevice.current.model,
            deviceModel: deviceModel,
            deviceStats: DeviceStatsPayload(
                deviceMemory: deviceMemoryGB,
                heapSizeLimit: nil,
                totalHeapSize: nil,
                usedHeapSize: nil,
                cpuCores: ProcessInfo.processInfo.processorCount,
                networkDownlink: nil,
                networkType: connectionTypeMonitor.lastConnectionTypeValue?.rawValue ?? "unknown",
                visibility: "visible"
            ),
            manufacturer: "Apple",
            appType: "app",
            pageUrl: nil,
            referrer: nil,
            os: UIDevice.current.systemName,
            osVersion: UIDevice.current.systemVersion,
            totalNumberOfDroppedFrames: nil,
            player: "bitmovin-player",
            version: BitmovinPlayerCore.PlayerFactory.sdkVersion,
            technology: nil,
            techVersion: nil,
            streamingTechnology: "HLS",
            cdnVendor: "unknown",
            analyticsPostInterval: Int(analytics.configuration.postInterval),
            analyticsBucket: Int(analytics.configuration.analyticsBucket),
            analyticsTag: analytics.configuration.analyticsTag,
            sdkVersion: PackageInfo.sdkVersion
        )
    }

    private var deviceModel: String {
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0,  count: Int(size))
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }

    private var deviceMemoryGB: Int {
        Int(ProcessInfo.processInfo.physicalMemory / 1024 / 1024 / 1024)
    }
}
