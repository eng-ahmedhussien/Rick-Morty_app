import Foundation
import Testing
@testable import Rick_Morty_app

@MainActor
@Suite
struct CharactersListViewModelTests {
    @Test func onAppearLoadsFirstPage() async {
        let repository = MockCharacterRepository()
        await repository.setResult(.success(Page(items: [Fixtures.character(id: 1)], hasNextPage: false)), forPage: 1)
        let sut = CharactersListViewModel(repository: repository)

        await sut.onAppear()

        #expect(sut.state == .loaded)
        #expect(sut.characters.map(\.id) == [1])
    }

    @Test func emptyResultSetsEmptyState() async {
        let repository = MockCharacterRepository()
        await repository.setResult(.success(Page(items: [], hasNextPage: false)), forPage: 1)
        let sut = CharactersListViewModel(repository: repository)

        await sut.onAppear()

        #expect(sut.state == .empty)
    }

    @Test func failureWithNothingFetchedSetsErrorState() async {
        let repository = MockCharacterRepository()
        await repository.setResult(.failure(NetworkError.noInternetConnection), forPage: 1)
        let sut = CharactersListViewModel(repository: repository)

        await sut.onAppear()

        guard case .error = sut.state else {
            Issue.record("Expected .error state, got \(sut.state)")
            return
        }
    }

    @Test func refreshFailureKeepsExistingCharactersVisible() async {
        let repository = MockCharacterRepository()
        await repository.setResult(.success(Page(items: [Fixtures.character(id: 1)], hasNextPage: false)), forPage: 1)
        let sut = CharactersListViewModel(repository: repository)
        await sut.onAppear()

        await repository.setResult(.failure(NetworkError.noInternetConnection), forPage: 1)
        await sut.refresh()

        #expect(sut.state == .loaded)
        #expect(sut.characters.count == 1)
    }

    @Test func loadNextPageIfNeededFetchesNextPageNearTheEnd() async {
        let repository = MockCharacterRepository()
        let firstPage = (1...10).map { Fixtures.character(id: $0, name: "Character \($0)") }
        await repository.setResult(.success(Page(items: firstPage, hasNextPage: true)), forPage: 1)
        await repository.setResult(.success(Page(items: [Fixtures.character(id: 11)], hasNextPage: false)), forPage: 2)
        let sut = CharactersListViewModel(repository: repository)
        await sut.onAppear()

        await sut.loadNextPageIfNeeded(currentItem: firstPage[9])

        #expect(sut.characters.count == 11)
        #expect(await repository.requestedPages == [1, 2])
    }

    @Test func loadNextPageIfNeededDoesNothingWhenFarFromTheEnd() async {
        let repository = MockCharacterRepository()
        let firstPage = (1...10).map { Fixtures.character(id: $0, name: "Character \($0)") }
        await repository.setResult(.success(Page(items: firstPage, hasNextPage: true)), forPage: 1)
        let sut = CharactersListViewModel(repository: repository)
        await sut.onAppear()

        await sut.loadNextPageIfNeeded(currentItem: firstPage[0])

        #expect(sut.characters.count == 10)
        #expect(await repository.requestedPages == [1])
    }

    @Test func duplicateCharactersAcrossPagesAreNotAppendedTwice() async {
        let repository = MockCharacterRepository()
        let character = Fixtures.character(id: 1)
        await repository.setResult(.success(Page(items: [character], hasNextPage: true)), forPage: 1)
        await repository.setResult(.success(Page(items: [character], hasNextPage: false)), forPage: 2)
        let sut = CharactersListViewModel(repository: repository)
        await sut.onAppear()

        await sut.loadNextPageIfNeeded(currentItem: character)

        #expect(sut.characters.count == 1)
    }

    @Test func sortOptionReordersCharacters() async {
        let repository = MockCharacterRepository()
        let items = [Fixtures.character(id: 1, name: "Zeta"), Fixtures.character(id: 2, name: "Alpha")]
        await repository.setResult(.success(Page(items: items, hasNextPage: false)), forPage: 1)
        let sut = CharactersListViewModel(repository: repository)
        await sut.onAppear()

        sut.sortOption = .nameAscending

        #expect(sut.characters.map(\.name) == ["Alpha", "Zeta"])
    }

    @Test func statusFilterChangeTriggersReloadWithNewFilter() async throws {
        let repository = MockCharacterRepository()
        await repository.setResult(.success(Page(items: [Fixtures.character(id: 1)], hasNextPage: false)), forPage: 1)
        let sut = CharactersListViewModel(repository: repository)
        await sut.onAppear()

        sut.statusFilter = .alive
        try await Task.sleep(for: .milliseconds(50))

        #expect(await repository.requestedFilters.last?.status == .alive)
    }

    @Test func searchTextChangeDebouncesBeforeReloading() async throws {
        let repository = MockCharacterRepository()
        await repository.setResult(.success(Page(items: [Fixtures.character(id: 1)], hasNextPage: false)), forPage: 1)
        let sut = CharactersListViewModel(repository: repository)
        await sut.onAppear()

        sut.searchText = "Rick"
        try await Task.sleep(for: .milliseconds(100))
        #expect(await repository.requestedFilters.count == 1)

        try await Task.sleep(for: .milliseconds(500))
        #expect(await repository.requestedFilters.last?.searchText == "Rick")
    }
}
