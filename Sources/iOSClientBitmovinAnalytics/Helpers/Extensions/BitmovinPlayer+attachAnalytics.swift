// SPDX-FileCopyrightText: 2026 Red Bee Media Ltd <https://www.redbeemedia.com/\>
//
// SPDX-License-Identifier: MIT

import BitmovinPlayer

extension BitmovinPlayer.Player {
    /// Enables automatic analytics tracking for this player instance using the provided adapter.
    public func attachAnalytics(
        using analyticsAdapter: BitmovinAnalyticsAdapter
    ) {
        analyticsAdapter.attach(to: self)
    }
}
