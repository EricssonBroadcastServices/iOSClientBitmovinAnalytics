// SPDX-FileCopyrightText: 2026 Red Bee Media Ltd <https://www.redbeemedia.com/\>
//
// SPDX-License-Identifier: MIT

import Foundation

struct DeviceStatsPayload: AnalyticsPayloadProtocol {
    let deviceMemory: Int
    let heapSizeLimit: Int?
    let totalHeapSize: Int?
    let usedHeapSize: Int?
    let cpuCores: Int
    let networkDownlink: Int?
    let networkType: String
    let visibility: String

    var asDictionary: [String: Any?] {
        [
            AnalyticsKeys.deviceMemory: deviceMemory,
            AnalyticsKeys.heapSizeLimit: heapSizeLimit,
            AnalyticsKeys.totalHeapSize: totalHeapSize,
            AnalyticsKeys.usedHeapSize: usedHeapSize,
            AnalyticsKeys.cpuCores: cpuCores,
            AnalyticsKeys.networkDownlink: networkDownlink,
            AnalyticsKeys.networkType: networkType,
            AnalyticsKeys.visibility: visibility
        ]
    }
}

// MARK: - Keys
extension AnalyticsKeys {
    static let deviceMemory = "deviceMemory"
    static let heapSizeLimit = "heapSizeLimit"
    static let totalHeapSize = "totalHeapSize"
    static let usedHeapSize = "usedHeapSize"
    static let cpuCores = "cpuCores"
    static let networkDownlink = "networkDownlink"
    static let networkType = "networkType"
    static let visibility = "visibility"
}
