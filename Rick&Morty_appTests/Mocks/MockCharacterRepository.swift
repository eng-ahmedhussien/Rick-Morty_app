import Foundation
@testable import Rick_Morty_app

actor MockCharacterRepository: CharacterRepositoryProtocol {
    enum StubResult {
        case success(Page<Character>)
        case failure(Error)
    }

    private var resultsByPage: [Int: StubResult] = [:]
    private var defaultResult: StubResult
    private(set) var requestedPages: [Int] = []
    private(set) var requestedFilters: [CharacterFilter] = []

    init(defaultResult: StubResult = .success(Page(items: [], hasNextPage: false))) {
        self.defaultResult = defaultResult
    }

    func setResult(_ result: StubResult, forPage page: Int) {
        resultsByPage[page] = result
    }

    func fetchCharacters(page: Int, filter: CharacterFilter) async throws -> Page<Character> {
        requestedPages.append(page)
        requestedFilters.append(filter)
        let result = resultsByPage[page] ?? defaultResult
        switch result {
        case .success(let page): return page
        case .failure(let error): throw error
        }
    }
}
