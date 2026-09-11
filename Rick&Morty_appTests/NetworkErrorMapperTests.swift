import Foundation
import Testing
@testable import Rick_Morty_app

@Suite
struct NetworkErrorMapperTests {
    @Test func mapsSuccessStatusCodesToNil() {
        #expect(NetworkErrorMapper.mapHTTPStatus(200, data: nil) == nil)
        #expect(NetworkErrorMapper.mapHTTPStatus(299, data: nil) == nil)
    }

    @Test func maps404ToNotFound() {
        guard case .notFound = NetworkErrorMapper.mapHTTPStatus(404, data: nil) else {
            Issue.record("Expected .notFound")
            return
        }
    }

    @Test func maps5xxToServerError() {
        guard case .serverError(let statusCode, _) = NetworkErrorMapper.mapHTTPStatus(503, data: nil) else {
            Issue.record("Expected .serverError")
            return
        }
        #expect(statusCode == 503)
    }

    @Test func mapsOtherStatusCodesToHTTP() {
        guard case .http(let statusCode, _) = NetworkErrorMapper.mapHTTPStatus(418, data: nil) else {
            Issue.record("Expected .http")
            return
        }
        #expect(statusCode == 418)
    }

    @Test func mapsURLErrorNotConnected() {
        guard case .noInternetConnection = NetworkErrorMapper.map(URLError(.notConnectedToInternet)) else {
            Issue.record("Expected .noInternetConnection")
            return
        }
    }

    @Test func mapsURLErrorTimedOut() {
        guard case .timeout = NetworkErrorMapper.map(URLError(.timedOut)) else {
            Issue.record("Expected .timeout")
            return
        }
    }

    @Test func mapsURLErrorCancelled() {
        guard case .cancelled = NetworkErrorMapper.map(URLError(.cancelled)) else {
            Issue.record("Expected .cancelled")
            return
        }
    }

    @Test func passesThroughExistingNetworkError() {
        guard case .notFound = NetworkErrorMapper.map(NetworkError.notFound) else {
            Issue.record("Expected passthrough .notFound")
            return
        }
    }
}
