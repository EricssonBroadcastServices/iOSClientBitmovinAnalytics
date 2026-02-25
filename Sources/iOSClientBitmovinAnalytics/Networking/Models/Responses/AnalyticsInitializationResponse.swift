// SPDX-FileCopyrightText: 2026 Red Bee Media Ltd <https://www.redbeemedia.com/\>
//
// SPDX-License-Identifier: MIT

import Foundation

struct AnalyticsInitializationResponse: Decodable {
    /// Unix epoch time in milliseconds
    let receivedTime: Int64?

    /// Unix epoch time in milliseconds
    let repliedTime: Int64?

    /// *Exposure* analytics environment data
    let settings: AnalyticsConfigResponse?
}
