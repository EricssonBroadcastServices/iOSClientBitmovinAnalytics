// SPDX-FileCopyrightText: 2026 Red Bee Media Ltd <https://www.redbeemedia.com/\>
//
// SPDX-License-Identifier: MIT

import Foundation

extension Dictionary where Key == String, Value == Any? {
    func compactMapValuesRecursively() -> [String: Any] {
        self.compactMapValues { value in
            switch value {
            case nil:
                return nil
            case let dict as [String: Any?]:
                return dict.compactMapValuesRecursively()
            default:
                return value
            }
        }
    }
}
