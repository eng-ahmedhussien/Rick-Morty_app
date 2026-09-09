import Foundation

protocol CharacterRemoteDataSource: Sendable {
    func fetchCharacters(page: Int, filter: CharacterFilter) async throws -> PagedResponse<CharacterDTO>
}

struct DefaultCharacterRemoteDataSource: CharacterRemoteDataSource {
    let httpClient: HTTPClient

    func fetchCharacters(page: Int, filter: CharacterFilter) async throws -> PagedResponse<CharacterDTO> {
        try await httpClient.send(CharacterEndpoint.list(page: page, filter: filter))
    }
}
