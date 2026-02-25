// SPDX-FileCopyrightText: 2026 Red Bee Media Ltd <https://www.redbeemedia.com/\>
//
// SPDX-License-Identifier: MIT

import UIKit
import Combine

enum AppLifecycleEvent {
    case resumed
    case backgrounded
}

struct AppLifecyclePublisher {
    static var publisher: AnyPublisher<AppLifecycleEvent, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIApplication.didBecomeActiveNotification)
                .map { _ in .resumed },

            NotificationCenter.default
                .publisher(for: UIApplication.didEnterBackgroundNotification)
                .map { _ in .backgrounded }
        )
        .eraseToAnyPublisher()
    }
}
