import Foundation
import Testing
@testable import Rick_Morty_app

@MainActor
@Suite
struct CharacterDetailsViewModelTests {
    @Test func emptyEpisodeIDsSkipsNetworkCall() async {
        let character = Fixtures.character(episodeIDs: [])
        let repository = MockEpisodeRepository()
        let sut = CharacterDetailsViewModel(character: character, episodeRepository: repository)

        await sut.loadEpisodesIfNeeded()

        #expect(sut.episodesState == .loaded([]))
        #expect(await repository.requestedIDs.isEmpty)
    }

    @Test func loadsEpisodesSuccessfully() async {
        let character = Fixtures.character(episodeIDs: [1, 2])
        let repository = MockEpisodeRepository(result: .success([Fixtures.episode(id: 1), Fixtures.episode(id: 2)]))
        let sut = CharacterDetailsViewModel(character: character, episodeRepository: repository)

        await sut.loadEpisodesIfNeeded()

        #expect(sut.episodesState == .loaded([Fixtures.episode(id: 1), Fixtures.episode(id: 2)]))
    }

    @Test func loadEpisodesIfNeededIsNoOpAfterFirstLoad() async {
        let character = Fixtures.character(episodeIDs: [1])
        let repository = MockEpisodeRepository(result: .success([Fixtures.episode(id: 1)]))
        let sut = CharacterDetailsViewModel(character: character, episodeRepository: repository)

        await sut.loadEpisodesIfNeeded()
        await sut.loadEpisodesIfNeeded()

        #expect(await repository.requestedIDs.count == 1)
    }

    @Test func networkFailureSetsErrorState() async {
        let character = Fixtures.character(episodeIDs: [1])
        let repository = MockEpisodeRepository(result: .failure(NetworkError.noInternetConnection))
        let sut = CharacterDetailsViewModel(character: character, episodeRepository: repository)

        await sut.loadEpisodesIfNeeded()

        guard case .error = sut.episodesState else {
            Issue.record("Expected .error state, got \(sut.episodesState)")
            return
        }
    }

    @Test func retryReloadsAfterFailure() async {
        let character = Fixtures.character(episodeIDs: [1])
        let repository = MockEpisodeRepository(result: .failure(NetworkError.noInternetConnection))
        let sut = CharacterDetailsViewModel(character: character, episodeRepository: repository)
        await sut.loadEpisodesIfNeeded()

        await repository.setResult(.success([Fixtures.episode(id: 1)]))
        await sut.retry()

        #expect(sut.episodesState == .loaded([Fixtures.episode(id: 1)]))
    }
}
