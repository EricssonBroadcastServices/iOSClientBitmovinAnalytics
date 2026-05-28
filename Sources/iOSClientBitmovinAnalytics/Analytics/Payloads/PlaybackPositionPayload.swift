// SPDX-FileCopyrightText: 2026 Red Bee Media Ltd <https://www.redbeemedia.com/\>
//
// SPDX-License-Identifier: MIT

import Foundation

struct PlaybackPositionPayload: AnalyticsPayloadProtocol {
    let playbackPosition: TimeInterval

    var asDictionary: [String: Any?] {
        [
            AnalyticsKeys.playbackPosition: playbackPosition
        ]
    }
}

// MARK: - Keys
extension AnalyticsKeys {
    static let playbackPosition = "PlaybackPosition"
}
