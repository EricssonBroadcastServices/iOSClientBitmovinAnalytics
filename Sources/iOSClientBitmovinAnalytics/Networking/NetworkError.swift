// SPDX-FileCopyrightText: 2026 Red Bee Media Ltd <https://www.redbeemedia.com/\>
//
// SPDX-License-Identifier: MIT

import Foundation

enum NetworkError: Error {
    case offline
    case serverError(Int, Data)
    case clientError(Int, Data)
    case tooManyRequests(Int, Data)
    case invalidHTTPResponse
    case responseDecodingFailed(Error)
    case requestFailed(Error)

    var isRetryable: Bool {
        switch self {
        case .offline, .serverError, .tooManyRequests:
            return true
        case .clientError, .invalidHTTPResponse, .responseDecodingFailed, .requestFailed:
            return false
        }
    }
}
