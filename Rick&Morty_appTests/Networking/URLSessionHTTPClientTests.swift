import Foundation
import Testing
@testable import Rick_Morty_app

/// Serialized because every test drives the same static `URLProtocolStub.stub`.
@Suite(.serialized)
struct URLSessionHTTPClientTests {
    private func makeSUT() -> URLSessionHTTPClient {
        URLSessionHTTPClient(session: URLProtocolStub.makeSession())
    }

    @Test func decodesSuccessfulResponse() async throws {
        URLProtocolStub.stub = .init(statusCode: 200, data: characterJSON(), error: nil)
        let sut = makeSUT()

        let dto: CharacterDTO = try await sut.send(CharacterEndpoint.list(page: 1, filter: .none))

        #expect(dto.name == "Rick Sanchez")
    }

    @Test func throwsNotFoundOn404() async {
        URLProtocolStub.stub = .init(statusCode: 404, data: Data(), error: nil)
        let sut = makeSUT()

        do {
            let _: CharacterDTO = try await sut.send(CharacterEndpoint.list(page: 1, filter: .none))
            Issue.record("Expected an error to be thrown")
        } catch let error as NetworkError {
            guard case .notFound = error else {
                Issue.record("Expected .notFound, got \(error)")
                return
            }
        } catch {
            Issue.record("Expected NetworkError, got \(error)")
        }
    }

    @Test func throwsServerErrorOn500() async {
        URLProtocolStub.stub = .init(statusCode: 500, data: Data(), error: nil)
        let sut = makeSUT()

        do {
            let _: CharacterDTO = try await sut.send(CharacterEndpoint.list(page: 1, filter: .none))
            Issue.record("Expected an error to be thrown")
        } catch let error as NetworkError {
            guard case .serverError(let statusCode, _) = error else {
                Issue.record("Expected .serverError, got \(error)")
                return
            }
            #expect(statusCode == 500)
        } catch {
            Issue.record("Expected NetworkError, got \(error)")
        }
    }

    @Test func throwsEmptyResponseOnEmptyBody() async {
        URLProtocolStub.stub = .init(statusCode: 200, data: Data(), error: nil)
        let sut = makeSUT()

        do {
            let _: CharacterDTO = try await sut.send(CharacterEndpoint.list(page: 1, filter: .none))
            Issue.record("Expected an error to be thrown")
        } catch let error as NetworkError {
            guard case .emptyResponse = error else {
                Issue.record("Expected .emptyResponse, got \(error)")
                return
            }
        } catch {
            Issue.record("Expected NetworkError, got \(error)")
        }
    }

    @Test func throwsDecodingErrorOnMalformedJSON() async {
        URLProtocolStub.stub = .init(statusCode: 200, data: Data("{ not valid".utf8), error: nil)
        let sut = makeSUT()

        do {
            let _: CharacterDTO = try await sut.send(CharacterEndpoint.list(page: 1, filter: .none))
            Issue.record("Expected an error to be thrown")
        } catch let error as NetworkError {
            guard case .decoding = error else {
                Issue.record("Expected .decoding, got \(error)")
                return
            }
        } catch {
            Issue.record("Expected NetworkError, got \(error)")
        }
    }

    private func characterJSON() -> Data {
        Data("""
        {
            "id": 1,
            "name": "Rick Sanchez",
            "status": "Alive",
            "species": "Human",
            "type": "",
            "gender": "Male",
            "origin": {"name": "Earth", "url": ""},
            "location": {"name": "Earth", "url": ""},
            "image": "https://example.com/1.png",
            "episode": [],
            "url": "",
            "created": ""
        }
        """.utf8)
    }
}
