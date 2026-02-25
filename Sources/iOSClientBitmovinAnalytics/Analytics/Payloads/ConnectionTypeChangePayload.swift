// SPDX-FileCopyrightText: 2026 Red Bee Media Ltd <https://www.redbeemedia.com/\>
//
// SPDX-License-Identifier: MIT

import Foundation

struct ConnectionTypeChangePayload: AnalyticsPayloadProtocol {
    let connectionType: String

    var asDictionary: [String: Any?] {
        [
            AnalyticsKeys.connectionType: connectionType,
        ]
    }
}

// MARK: - Keys
extension AnalyticsKeys {
    static let connectionType = "ConnectionType"
}
