import Foundation
@testable import Rick_Morty_app

actor MockCharacterRemoteDataSource: CharacterRemoteDataSource {
    enum StubResult {
        case success(PagedResponse<CharacterDTO>)
        case failure(Error)
    }

    private var result: StubResult

    init(result: StubResult = .failure(NetworkError.unknown(message: "not configured"))) {
        self.result = result
    }

    func setResult(_ result: StubResult) {
        self.result = result
    }

    func fetchCharacters(page: Int, filter: CharacterFilter) async throws -> PagedResponse<CharacterDTO> {
        switch result {
        case .success(let response): return response
        case .failure(let error): throw error
        }
    }
}
