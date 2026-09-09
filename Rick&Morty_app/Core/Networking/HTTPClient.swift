//
//  HTTPClient.swift
//  HTTPClient
//
//  Created by Ahmed on 09/09/2026.
//

import Foundation


protocol HTTPClient: Sendable {
    func send<E: Endpoint, T: Decodable & Sendable>(_ endpoint: E) async throws -> T
}

struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        session: URLSession = URLSessionHTTPClient.makeSession(),
        decoder: JSONDecoder = .rickAndMortyDefault
    ) {
        self.session = session
        self.decoder = decoder
    }

    func send<E: Endpoint, T: Decodable & Sendable>(_ endpoint: E) async throws -> T {
        let request: URLRequest
        do {
            request = try endpoint.asURLRequest()
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.encoding(message: error.localizedDescription)
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NetworkErrorMapper.map(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown(message: "Non-HTTP response received.")
        }

        if let statusError = NetworkErrorMapper.mapHTTPStatus(httpResponse.statusCode, data: data) {
            throw statusError
        }

        guard !data.isEmpty else {
            throw NetworkError.emptyResponse
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            throw NetworkError.decoding(underlying: decodingError)
        } catch {
            throw NetworkError.unknown(message: error.localizedDescription)
        }
    }

    private static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        configuration.timeoutIntervalForResource = 60
        configuration.waitsForConnectivity = false
        return URLSession(configuration: configuration)
    }
}

extension JSONDecoder {
    static var rickAndMortyDefault: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
