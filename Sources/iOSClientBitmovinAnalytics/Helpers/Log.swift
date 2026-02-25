// SPDX-FileCopyrightText: 2026 Red Bee Media Ltd <https://www.redbeemedia.com/\>
//
// SPDX-License-Identifier: MIT

import Foundation

func logError(_ message: String, error: Error? = nil) {
    #if DEBUG
    if let error {
        print("[iOSClientBitmovinAnalytics] ⚠️ \(message): \(error.localizedDescription)")
    } else {
        print("[iOSClientBitmovinAnalytics] ⚠️ \(message)")
    }
    #endif
}

func logInfo(_ message: String) {
    #if DEBUG
        print("[iOSClientBitmovinAnalytics] \(message)")
    #endif
}
