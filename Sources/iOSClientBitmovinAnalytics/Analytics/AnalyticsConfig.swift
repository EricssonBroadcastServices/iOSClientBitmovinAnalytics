// SPDX-FileCopyrightText: 2026 Red Bee Media Ltd <https://www.redbeemedia.com/\>
//
// SPDX-License-Identifier: MIT

import Foundation

public struct AnalyticsConfiguration {
    public let baseURL: String
    public let businessUnit: String
    public let customer: String
    public let sessionID: String
    public let requestID: String?
    public let sessionToken: String
    public let postInterval: Int
    public let analyticsBucket: Int
    public let analyticsTag: String

    /// Creates analytics configuration for BitmovinAnalyticsAdapter with values from the play response.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL of the analytics service.
    ///   - businessUnit: Business Unit identifier.
    ///   - customer: Customer Group identifier.
    ///   - sessionID: Playback session identifier.
    ///   - requestID: Backend request identifier.
    ///   - sessionToken: Token representing an authenticated user session.
    ///   - postInterval: Interval for sending analytics events (from play response).
    ///   - analyticsBucket: Analytics bucket (from play response).
    ///   - analyticsTag: Analytics tag (from play response).
    public init(
        baseURL: String,
        businessUnit: String,
        customer: String,
        sessionID: String,
        requestID: String?,
        sessionToken: String,
        postInterval: Int,
        analyticsBucket: Int,
        analyticsTag: String
    ) {
        self.baseURL = baseURL
        self.businessUnit = businessUnit
        self.customer = customer
        self.sessionID = sessionID
        self.requestID = requestID
        self.sessionToken = sessionToken
        self.postInterval = postInterval
        self.analyticsBucket = analyticsBucket
        self.analyticsTag = analyticsTag
    }
}
