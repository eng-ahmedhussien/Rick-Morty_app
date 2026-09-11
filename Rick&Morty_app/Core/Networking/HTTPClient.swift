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
        let request = try Self.makeRequest(from: endpoint)
        NetworkLogger.logRequest(request)

        do {
            let (data, httpResponse) = try await performRequest(request)
            NetworkLogger.logResponse(request: request, response: httpResponse, data: data)
            return try decode(data)
        } catch {
            NetworkLogger.logError(request: request, error: String(describing: error))
            throw error
        }
    }

    // MARK: - Steps

    private func performRequest(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
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

        return (data, httpResponse)
    }

    private func decode<T: Decodable>(_ data: Data) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            throw NetworkError.decoding(underlying: decodingError)
        } catch {
            throw NetworkError.unknown(message: error.localizedDescription)
        }
    }

    private static func makeRequest(from endpoint: some Endpoint) throws -> URLRequest {
        do {
            return try endpoint.asURLRequest()
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.encoding(message: error.localizedDescription)
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
    /// `air_date` on episodes is the only snake_case field the API returns;
    /// everything else is already single lowercase words.
    static var rickAndMortyDefault: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
