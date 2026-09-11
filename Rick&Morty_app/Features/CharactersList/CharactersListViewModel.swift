//
//  CharactersListViewModel.swift
//  CharactersListViewModel
//
//  Created by Ahmed on 11/09/2026.
//

import Foundation

@MainActor
@Observable
final class CharactersListViewModel {

    enum State: Equatable {
        case idle
        case loading
        case loaded
        case empty
        case error(String)
    }

    private(set) var state: State = .idle
    private(set) var characters: [Character] = []
    private(set) var isLoadingNextPage = false
    private(set) var isRefreshing = false

    var searchText = "" {
        didSet {
            guard oldValue != searchText else { return }
            debounceSearch()
        }
    }

    var statusFilter: CharacterStatus? {
        didSet {
            guard oldValue != statusFilter else { return }
            Task { await performInitialLoad() }
        }
    }

    var sortOption: CharacterSortOption = .none {
        didSet {
            guard oldValue != sortOption else { return }
            applySorting()
        }
    }

    private let repository: CharacterRepositoryProtocol
    private var page = 1
    private var hasNextPage = false
    private var seenIDs = Set<Int>() //search O(1)
    private var fetched: [Character] = []

    init(repository: CharacterRepositoryProtocol) {
        self.repository = repository
    }

    private var filter: CharacterFilter {
        CharacterFilter(
            searchText: searchText.trimmingCharacters(in: .whitespacesAndNewlines),
            status: statusFilter
        )
    }

    // MARK: - Intent

    func onAppear() async {
        guard state == .idle else { return }
        await performInitialLoad()
    }

    func refresh() async {
        isRefreshing = true
        await performInitialLoad()
        isRefreshing = false
    }

    func retry() async {
        await performInitialLoad()
    }

    /// Called as each row appears. Triggers the next page once the user is
    /// within five rows of the end.
    func loadNextPageIfNeeded(currentItem: Character) async {
        guard state == .loaded, hasNextPage, !isLoadingNextPage else { return }
       /// guard let index = characters.firstIndex(of: currentItem) else { return } //O(n).
        ///guard index >= characters.count - 5 else { return }
        guard characters.suffix(5).contains(where: { $0.id == currentItem.id }) else { return }
       
        await loadNextPage()
    }

    // MARK: - Loading

    private func performInitialLoad() async {
        if !isRefreshing { state = .loading }
      
        let requested = filter
        do {
            let result = try await repository.fetchCharacters(page: 1, filter: requested)
            page = 1
            seenIDs = []
            fetched = removeDuplicates(from: result.items)
            hasNextPage = result.hasNextPage
            state = fetched.isEmpty ? .empty : .loaded
            applySorting()
        } catch {
            // only surface the error screen when there's nothing to show.
            state = fetched.isEmpty ? .error(Self.describe(error)) : .loaded
        }
    }
    
    private func loadNextPage() async {
        isLoadingNextPage = true
        defer { isLoadingNextPage = false }

        let requested = filter
        let nextPage = page + 1
        do {
            let result = try await repository.fetchCharacters(page: nextPage, filter: requested)
            let newItems = removeDuplicates(from: result.items)
            fetched.append(contentsOf: newItems)
            applySorting()
            page = nextPage
            hasNextPage = result.hasNextPage
        } catch {
            hasNextPage = false
        }
    }

    private func debounceSearch() {
         Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(400))
            guard let self, !Task.isCancelled else { return }
            await self.performInitialLoad()
        }
    }

    private func applySorting() {
        characters = sortOption.apply(to: fetched)
    }

    private static func describe(_ error: Error) -> String {
        if let network = error as? NetworkError {
            return network.errorDescription ?? "Something went wrong."
        }
        return error.localizedDescription
    }
    
    private func removeDuplicates(from items: [Character]) -> [Character] {
        var newItems: [Character] = []
        for item in items {
            if !seenIDs.contains(item.id) {
                seenIDs.insert(item.id)
                newItems.append(item)
            }
        }
        return newItems
    }
}
