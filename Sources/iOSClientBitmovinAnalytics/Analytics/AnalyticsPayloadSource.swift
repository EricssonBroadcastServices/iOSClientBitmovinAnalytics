// SPDX-FileCopyrightText: 2026 Red Bee Media Ltd <https://www.redbeemedia.com/\>
//
// SPDX-License-Identifier: MIT

import Foundation

enum AnalyticsPayloadSource {
    case events([[String: Any]])
    case timeChanged([String: Any])
    case none

    var value: [[String: Any]] {
        switch self {
        case .events(let events): events
        case .timeChanged(let event): [event]
        case .none: []
        }
    }

    var isEmpty: Bool {
        switch self {
        case .events, .timeChanged: false
        case .none: true
        }
    }
}
