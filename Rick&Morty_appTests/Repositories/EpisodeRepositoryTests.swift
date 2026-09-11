import Foundation
import SwiftData
import Testing
@testable import Rick_Morty_app

@Suite
struct EpisodeRepositoryTests {
    private func makeLocalStore() throws -> LocalStore {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: CachedCharacter.self, CachedEpisode.self,
            configurations: configuration
        )
        return LocalStore(modelContainer: container)
    }

    @Test func returnsEmptyArrayForEmptyIDsWithoutTouchingTheNetwork() async throws {
        let localStore = try makeLocalStore()
        let remote = MockEpisodeRemoteDataSource()
        let sut = EpisodeRepository(remoteDataSource: remote, localStore: localStore)

        let episodes = try await sut.fetchEpisodes(ids: [])

        #expect(episodes.isEmpty)
        #expect(await remote.requestedIDs.isEmpty)
    }

    @Test func skipsNetworkWhenEverythingIsCached() async throws {
        let localStore = try makeLocalStore()
        try await localStore.cacheEpisodes([Fixtures.episode(id: 1), Fixtures.episode(id: 2)])
        let remote = MockEpisodeRemoteDataSource()
        let sut = EpisodeRepository(remoteDataSource: remote, localStore: localStore)

        let episodes = try await sut.fetchEpisodes(ids: [1, 2])

        #expect(episodes.map(\.id) == [1, 2])
        #expect(await remote.requestedIDs.isEmpty)
    }

    @Test func fetchesOnlyMissingIDs() async throws {
        let localStore = try makeLocalStore()
        try await localStore.cacheEpisodes([Fixtures.episode(id: 1)])
        let remote = MockEpisodeRemoteDataSource(result: .success([Fixtures.episodeDTO(id: 2)]))
        let sut = EpisodeRepository(remoteDataSource: remote, localStore: localStore)

        let episodes = try await sut.fetchEpisodes(ids: [1, 2])

        #expect(episodes.map(\.id) == [1, 2])
        #expect(await remote.requestedIDs == [[2]])
    }

    @Test func preservesRequestedOrderRegardlessOfFetchOrder() async throws {
        let localStore = try makeLocalStore()
        try await localStore.cacheEpisodes([Fixtures.episode(id: 5)])
        let remote = MockEpisodeRemoteDataSource(result: .success([
            Fixtures.episodeDTO(id: 3), Fixtures.episodeDTO(id: 1)
        ]))
        let sut = EpisodeRepository(remoteDataSource: remote, localStore: localStore)

        let episodes = try await sut.fetchEpisodes(ids: [3, 5, 1])

        #expect(episodes.map(\.id) == [3, 5, 1])
    }

    @Test func fallsBackToPartialCacheOnNetworkFailure() async throws {
        let localStore = try makeLocalStore()
        try await localStore.cacheEpisodes([Fixtures.episode(id: 1)])
        let remote = MockEpisodeRemoteDataSource(result: .failure(URLError(.notConnectedToInternet)))
        let sut = EpisodeRepository(remoteDataSource: remote, localStore: localStore)

        let episodes = try await sut.fetchEpisodes(ids: [1, 2])

        #expect(episodes.map(\.id) == [1])
    }

    @Test func rethrowsErrorWhenNothingIsCached() async throws {
        let localStore = try makeLocalStore()
        let remote = MockEpisodeRemoteDataSource(result: .failure(URLError(.notConnectedToInternet)))
        let sut = EpisodeRepository(remoteDataSource: remote, localStore: localStore)

        await #expect(throws: (any Error).self) {
            _ = try await sut.fetchEpisodes(ids: [99])
        }
    }
}
