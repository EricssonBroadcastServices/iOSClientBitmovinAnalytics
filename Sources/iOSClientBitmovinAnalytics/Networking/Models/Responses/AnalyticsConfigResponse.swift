// SPDX-FileCopyrightText: 2026 Red Bee Media Ltd <https://www.redbeemedia.com/\>
//
// SPDX-License-Identifier: MIT

import Foundation

struct AnalyticsConfigResponse: Codable {
    /// The requested time untill next contact with the *Analytics Engine*
    var secondsUntilNextReport: Int64?

    /// If application metrics should  be included when sending payload
    let includeApplicationMetrics: Bool?

    /// If network metrics should  be included when sending payload
    let includeNetworkMetrics: Bool?

    /// If *GPS* metrics should  be included when sending payload
    let includeGpsMetrics: Bool?

    /// If *device* metrics should  be included when sending payload
    let includeDeviceMetrics: Bool?

    /// The current timestamp, in unix epoch time.
    let timestampNow: Int64?

    init(
        secondsUntilNextReport: Int64? = nil ,
        includeApplicationMetrics: Bool? = nil ,
        includeNetworkMetrics: Bool? = nil ,
        includeGpsMetrics: Bool? = nil,
        includeDeviceMetrics: Bool? = nil ,
        timestampNow: Int64? = nil
    ) {
        self.secondsUntilNextReport = secondsUntilNextReport
        self.includeApplicationMetrics = includeApplicationMetrics
        self.includeNetworkMetrics = includeNetworkMetrics
        self.includeGpsMetrics = includeGpsMetrics
        self.includeDeviceMetrics = includeDeviceMetrics
        self.timestampNow = timestampNow
    }
}

