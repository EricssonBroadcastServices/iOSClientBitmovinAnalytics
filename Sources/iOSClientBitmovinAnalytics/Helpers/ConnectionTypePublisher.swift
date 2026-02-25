// SPDX-FileCopyrightText: 2026 Red Bee Media Ltd <https://www.redbeemedia.com/\>
//
// SPDX-License-Identifier: MIT

import Combine
import Network

enum ConnectionType: String {
    case none
    case unknown
    case cellular
    case wifi
    case ethernet
    case vpn
    case other
}

protocol ConnectionTypeMonitorProtocol: ObservableObject {
    var connectionTypePublisher: AnyPublisher<ConnectionType, Never> { get }
    var lastConnectionTypeValue: ConnectionType? { get }
}

final class ConnectionTypeMonitor: ConnectionTypeMonitorProtocol {
    @Published private(set) var connectionType: ConnectionType?

    var lastConnectionTypeValue: ConnectionType? { connectionType }

    var connectionTypePublisher: AnyPublisher<ConnectionType, Never> {
        $connectionType
            .removeDuplicates()
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    init() {
        Task { [weak self] in
            let monitor: NWPathMonitor = NWPathMonitor()
            for await path in monitor.paths() {
                self?.connectionType = self?.mapPathToConnectionType(path)
            }
        }
    }

    private func mapPathToConnectionType(_ path: NWPath) -> ConnectionType {
        switch path.availableInterfaces.first(where: { path.usesInterfaceType($0.type) })?.type {
        case .wifi: .wifi
        case .cellular: .cellular
        case .wiredEthernet: .ethernet
        case .other: .other
        case .none: .none
        default: .unknown
        }
    }
}

extension NWPathMonitor {
    func paths() -> AsyncStream<NWPath> {
        AsyncStream { continuation in
            pathUpdateHandler = { path in
                continuation.yield(path)
            }
            continuation.onTermination = { [weak self] _ in
                self?.cancel()
            }
            start(queue: DispatchQueue(label: "iOSClientBitmovinAnalytics.NWPathMonitor"))
        }
    }
}
