import Foundation
import SwiftData
import Testing
@testable import Rick_Morty_app

@Suite
struct CharacterRepositoryTests {
    private func makeLocalStore() throws -> LocalStore {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: CachedCharacter.self, CachedEpisode.self,
            configurations: configuration
        )
        return LocalStore(modelContainer: container)
    }

    @Test func fetchSucceedsAndCachesResults() async throws {
        let localStore = try makeLocalStore()
        let remote = MockCharacterRemoteDataSource(result: .success(
            PagedResponse(
                info: PageInfoDTO(count: 1, pages: 1, next: nil, prev: nil),
                results: [Fixtures.characterDTO(id: 1, name: "Rick Sanchez")]
            )
        ))
        let repository = CharacterRepository(remoteDataSource: remote, localStore: localStore)

        let page = try await repository.fetchCharacters(page: 1, filter: .none)

        #expect(page.items.map(\.name) == ["Rick Sanchez"])
        #expect(page.hasNextPage == false)

        let cached = try await localStore.cachedCharacters(matching: .none)
        #expect(cached.count == 1)
    }

    @Test func reportsHasNextPageWhenNextURLPresent() async throws {
        let localStore = try makeLocalStore()
        let remote = MockCharacterRemoteDataSource(result: .success(
            PagedResponse(
                info: PageInfoDTO(count: 2, pages: 2, next: "https://rickandmortyapi.com/api/character?page=2", prev: nil),
                results: [Fixtures.characterDTO()]
            )
        ))
        let repository = CharacterRepository(remoteDataSource: remote, localStore: localStore)

        let page = try await repository.fetchCharacters(page: 1, filter: .none)

        #expect(page.hasNextPage == true)
    }

    @Test func notFoundIsTreatedAsEmptyResultNotFailure() async throws {
        let localStore = try makeLocalStore()
        let remote = MockCharacterRemoteDataSource(result: .failure(NetworkError.notFound))
        let sut = CharacterRepository(remoteDataSource: remote, localStore: localStore)

        let page = try await sut.fetchCharacters(page: 1, filter: CharacterFilter(searchText: "nobody"))

        #expect(page.items.isEmpty)
        #expect(page.hasNextPage == false)
    }

    @Test func fallsBackToCacheOnNetworkFailure() async throws {
        let localStore = try makeLocalStore()
        try await localStore.cacheCharacters([Fixtures.character(id: 1, name: "Cached Rick")])
        let remote = MockCharacterRemoteDataSource(result: .failure(URLError(.notConnectedToInternet)))
        let sut = CharacterRepository(remoteDataSource: remote, localStore: localStore)

        let page = try await sut.fetchCharacters(page: 1, filter: .none)

        #expect(page.items.map(\.name) == ["Cached Rick"])
        #expect(page.hasNextPage == false)
    }

    @Test func rethrowsErrorWhenCacheIsAlsoEmpty() async throws {
        let localStore = try makeLocalStore()
        let remote = MockCharacterRemoteDataSource(result: .failure(URLError(.notConnectedToInternet)))
        let sut = CharacterRepository(remoteDataSource: remote, localStore: localStore)

        await #expect(throws: (any Error).self) {
            _ = try await sut.fetchCharacters(page: 1, filter: .none)
        }
    }
}
