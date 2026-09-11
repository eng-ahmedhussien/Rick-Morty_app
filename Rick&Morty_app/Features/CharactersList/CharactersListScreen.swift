//
//  CharactersListView.swift
//  CharactersListView
//
//  Created by Ahmed on 11/09/2026.
//

import SwiftUI

struct CharactersListScreen: View {
    @State private var viewModel: CharactersListViewModel
    private let episodeRepository: EpisodeRepositoryProtocol

    init(
        characterRepository: CharacterRepositoryProtocol,
        episodeRepository: EpisodeRepositoryProtocol
    ) {
        _viewModel = State(initialValue: CharactersListViewModel(repository: characterRepository))
        self.episodeRepository = episodeRepository
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Characters")
                .searchable(text: $viewModel.searchText, prompt: "Search by name")
                .toolbar { toolbarContent }
                .navigationDestination(for: Character.self) { character in
                    CharacterDetailsView(
                        character: character,
                        episodeRepository: episodeRepository
                    )
                }
        }
        .task { await viewModel.onAppear() }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            loadingSkeleton
        case .empty:
            EmptyStateView()

        case .error(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.retry() }
            }

        case .loaded:
            characterList
        }
    }

    private var characterList: some View {
        List {
            ForEach(viewModel.characters) { character in
                NavigationLink(value: character) {
                    CharacterRowView(character: character)
                }
                .task { await viewModel.loadNextPageIfNeeded(currentItem: character) }
            }

            if viewModel.isLoadingNextPage {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .refreshable { await viewModel.refresh() }
    }

    private var loadingSkeleton: some View {
        List(Self.placeholderCharacters) { character in
            CharacterRowView(character: character)
        }
        .listStyle(.plain)
        .redacted(reason: .placeholder)
        .disabled(true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Loading characters")
    }

    private static let placeholderCharacters: [Character] = (0..<8).map { index in
        Character(
            id: -(index + 1),
            name: "Loading Character Name",
            status: .unknown,
            species: "Species",
            type: nil,
            gender: .unknown,
            imageURL: nil,
            originName: "Origin",
            locationName: "Location",
            episodeIDs: []
        )
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Picker("Status", selection: $viewModel.statusFilter) {
                    Text("All").tag(CharacterStatus?.none)
                    ForEach(CharacterStatus.allCases) { status in
                        Text(status.rawValue).tag(status)
                    }
                }

                Picker("Sort", selection: $viewModel.sortOption) {
                    ForEach(CharacterSortOption.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
            } label: {
                Label("Filter and sort", systemImage: "line.3.horizontal.decrease.circle")
            }
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var container = AppContainer()
    CharactersListScreen(
        characterRepository: container.characterRepository,
        episodeRepository: container.episodeRepository
    )
}
#endif
