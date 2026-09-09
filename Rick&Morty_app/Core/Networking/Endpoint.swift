//
//  RickAndMortyAPI.swift
//  RickAndMortyAPI
//
//  Created by Ahmed on 09/09/2026.
//

import Foundation


enum RickAndMortyAPI {
    static let baseURL: URL = {
        guard let url = URL(string: "https://rickandmortyapi.com/api") else {
            fatalError("Invalid Rick & Morty API base URL.")
        }
        return url
    }()
}


protocol Endpoint: Sendable {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeader { get }
    var body: RequestBody { get }
    var queryItems: [URLQueryItem] { get }
}

extension Endpoint {
    var method: HTTPMethod { .get }
    var headers: HTTPHeader { .default }
    var body: RequestBody { .none }
    var queryItems: [URLQueryItem] { [] }

    func asURLRequest() throws -> URLRequest {
        guard var components = URLComponents(
            url: RickAndMortyAPI.baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        ) else {
            throw NetworkError.invalidURL
        }

        if !queryItems.isEmpty {
            components.queryItems = queryItems.filter { !($0.value?.isEmpty ?? true) }
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers.values.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        switch body {
        case .none:
            break
        case .json(let encodable):
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                request.httpBody = try JSONEncoder().encode(encodable)
            } catch {
                throw NetworkError.encoding(message: error.localizedDescription)
            }
        }

        return request
    }
}
