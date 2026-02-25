// SPDX-FileCopyrightText: 2026 Red Bee Media Ltd <https://www.redbeemedia.com/\>
//
// SPDX-License-Identifier: MIT

import Foundation

extension Date {
    var millisecondsSince1970: Int64 {
        return Int64((timeIntervalSince1970 * 1000.0).rounded())
    }
}
