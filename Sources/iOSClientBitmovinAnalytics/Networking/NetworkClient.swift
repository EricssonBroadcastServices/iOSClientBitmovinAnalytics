// SPDX-FileCopyrightText: 2026 Red Bee Media Ltd <https://www.redbeemedia.com/\>
//
// SPDX-License-Identifier: MIT

import Foundation

protocol NetworkClientProtocol {
    func performRequest<T: Decodable>(
        url: URL, method: HTTPMethod, headers: [String: String], body: Data?
    ) async throws -> T
    func performRequest(
        url: URL, method: HTTPMethod, headers: [String: String], body: Data?
    ) async throws
}

final class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.decoder = decoder
    }

    func performRequest<T: Decodable>(
        url: URL,
        method: HTTPMethod,
        headers: [String: String] = [:],
        body: Data?
    ) async throws -> T {
        let data = try await execute(url: url, method: method, headers: headers, body: body)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.responseDecodingFailed(error)
        }
    }

    func performRequest(
        url: URL,
        method: HTTPMethod,
        headers: [String: String] = [:],
        body: Data?
    ) async throws {
        _ = try await execute(url: url,method: method, headers: headers, body: body)
    }

    private func execute(
        url: URL,
        method: HTTPMethod,
        headers: [String: String],
        body: Data?
    ) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw mapURLError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidHTTPResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw mapHTTPStatus(code: httpResponse.statusCode, data: data)
        }

        return data
    }
}

// MARK: - Error related
extension NetworkClient {
    private func mapURLError(_ error: Error) -> NetworkError {
        guard let urlError = error as? URLError else {
            return .requestFailed(error)
        }
        switch urlError.code {
        case .notConnectedToInternet,
                .networkConnectionLost,
                .dnsLookupFailed,
                .cannotFindHost,
                .cannotConnectToHost,
                .dataNotAllowed,
                .timedOut:
            return .offline
        default:
            return .requestFailed(urlError)
        }
    }

    private func mapHTTPStatus(code: Int, data: Data) -> NetworkError {
        switch code {
        case 500...599: return .serverError(code, data)
        case 429: return .tooManyRequests(code, data)
        case 400...499: return .clientError(code, data)
        default: return .invalidHTTPResponse
        }
    }
}
