//
//  NetworkError.swift
//  NetworkError
//
//  Created by Ahmed on 09/09/2026.
//

import Foundation

enum NetworkError: Error, Sendable {
    case invalidURL
    case noInternetConnection
    case timeout
    case cancelled
    case transport(underlying: URLError)
    case http(statusCode: Int, data: Data?)
    case emptyResponse
    case decoding(underlying: DecodingError)
    case encoding(message: String)

    case notFound
    case serverError(statusCode: Int, data: Data?)
    case unknown(message: String)

    var isRetryable: Bool {
        switch self {
        case .timeout, .noInternetConnection, .transport:
            return true
        case .serverError:
            return true
        case .http(let statusCode, _):
            return statusCode == 429 || statusCode >= 500
        default:
            return false
        }
    }
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The request URL was invalid."
        case .noInternetConnection: return "No internet connection."
        case .timeout: return "The request timed out."
        case .cancelled: return "The request was cancelled."
        case .transport(let underlying): return underlying.localizedDescription
        case .http(let statusCode, _): return "Request failed with status code \(statusCode)."
        case .emptyResponse: return "The server returned an empty response."
        case .decoding: return "Failed to decode the server response."
        case .encoding(let message): return "Failed to encode the request body: \(message)"
        case .notFound: return "Resource not found (404)."
        case .serverError(let statusCode, _): return "Server error (\(statusCode))."
        case .unknown(let message): return message
        }
    }
}

enum NetworkErrorMapper {
    static func map(_ error: Error) -> NetworkError {
        if let networkError = error as? NetworkError {
            return networkError
        }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .noInternetConnection
            case .timedOut:
                return .timeout
            case .cancelled:
                return .cancelled
            default:
                return .transport(underlying: urlError)
            }
        }
        if let decodingError = error as? DecodingError {
            return .decoding(underlying: decodingError)
        }
        return .unknown(message: error.localizedDescription)
    }

    /// Returns `nil` for a successful status code, otherwise the mapped error.
    static func mapHTTPStatus(_ statusCode: Int, data: Data?) -> NetworkError? {
        switch statusCode {
        case 200..<300:
            return nil
        case 404:
            return .notFound
        case 500...599:
            return .serverError(statusCode: statusCode, data: data)
        default:
            return .http(statusCode: statusCode, data: data)
        }
    }
}
