// SPDX-FileCopyrightText: 2026 Red Bee Media Ltd <https://www.redbeemedia.com/\>
//
// SPDX-License-Identifier: MIT

import Foundation

struct DeviceInfoPayload: AnalyticsPayloadProtocol {
    let height: Int
    let width: Int
    let name: String
    let deviceModel: String
    let deviceStats: DeviceStatsPayload
    let manufacturer: String
    let appType: String
    let pageUrl: String?
    let referrer: String?
    let os: String
    let osVersion: String
    let totalNumberOfDroppedFrames: Int?
    let player: String
    let version: String
    let technology: String?
    let techVersion: String?
    let streamingTechnology: String
    let cdnVendor: String
    let analyticsPostInterval: Int
    let analyticsBucket: Int
    let analyticsTag: String
    let sdkVersion: String

    var asDictionary: [String: Any?] {
        [
            AnalyticsKeys.height: height,
            AnalyticsKeys.width: width,
            AnalyticsKeys.name: name,
            AnalyticsKeys.deviceModel: deviceModel,
            AnalyticsKeys.deviceStats: deviceStats.asDictionary,
            AnalyticsKeys.manufacturer: manufacturer,
            AnalyticsKeys.appType: appType,
            AnalyticsKeys.pageUrl: pageUrl,
            AnalyticsKeys.referrer: referrer,
            AnalyticsKeys.os: os,
            AnalyticsKeys.osVersion: osVersion,
            AnalyticsKeys.totalNumberOfDroppedFrames: totalNumberOfDroppedFrames,
            AnalyticsKeys.player: player,
            AnalyticsKeys.version: version,
            AnalyticsKeys.technology: technology,
            AnalyticsKeys.techVersion: techVersion,
            AnalyticsKeys.streamingTechnology: streamingTechnology,
            AnalyticsKeys.cdnVendor: cdnVendor,
            AnalyticsKeys.analyticsPostInterval: analyticsPostInterval,
            AnalyticsKeys.analyticsBucket: analyticsBucket,
            AnalyticsKeys.analyticsTag: analyticsTag,
            AnalyticsKeys.sdkVersion: sdkVersion
        ]
    }
}

// MARK: - Keys
extension AnalyticsKeys {
    static let height = "Height"
    static let width = "Width"
    static let name = "Name"
    static let deviceModel = "DeviceModel"
    static let deviceStats = "DeviceStats"
    static let manufacturer = "Manufacturer"
    static let appType = "AppType"
    static let pageUrl = "PageUrl"
    static let referrer = "Referrer"
    static let os = "OS"
    static let osVersion = "OSVersion"
    static let totalNumberOfDroppedFrames = "TotalNumberOfDroppedFrames"
    static let player = "Player"
    static let version = "Version"
    static let technology = "Technology"
    static let techVersion = "TechVersion"
    static let streamingTechnology = "StreamingTechnology"
    static let cdnVendor = "CDNVendor"
    static let analyticsPostInterval = "AnalyticsPostInterval"
    static let analyticsBucket = "AnalyticsBucket"
    static let analyticsTag = "AnalyticsTag"
    static let sdkVersion = "SdkVersion"
}
