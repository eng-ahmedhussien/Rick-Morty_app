import SwiftUI

struct CharacterDetailsView: View {
    @State private var viewModel: CharacterDetailsViewModel

    init(character: Character, episodeRepository: EpisodeRepositoryProtocol) {
        _viewModel = State(
            initialValue: CharacterDetailsViewModel(
                character: character,
                episodeRepository: episodeRepository
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                infoSection
                episodesSection
            }
            .padding()
        }
        .navigationTitle(viewModel.character.name)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadEpisodesIfNeeded() }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 12) {
            RemoteImageView(url: viewModel.character.imageURL)
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 20))

            Text(viewModel.character.name)
                .font(.title.bold())
                .multilineTextAlignment(.center)

            StatusBadgeView(status: viewModel.character.status)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Info

    private var infoSection: some View {
        GroupBox {
            VStack(spacing: 10) {
                LabeledContent("Species", value: viewModel.character.species)
                LabeledContent("Gender", value: viewModel.character.gender.rawValue.capitalized)
                if let type = viewModel.character.type {
                    LabeledContent("Type", value: type)
                }
                LabeledContent("Origin", value: viewModel.character.originName)
                LabeledContent("Location", value: viewModel.character.locationName)
            }
        }
    }

    // MARK: - Episodes

    private var episodesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Episodes")
                .font(.title2.bold())

            switch viewModel.episodesState {
            case .idle, .loading:
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Loading episodes…")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

            case .loaded(let episodes):
                if episodes.isEmpty {
                    Text("No episodes.")
                        .foregroundStyle(.secondary)
                } else {
                    episodeList(episodes)
                }

            case .error(let message):
                VStack(alignment: .leading, spacing: 8) {
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Button("Retry") {
                        Task { await viewModel.retry() }
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func episodeList(_ episodes: [Episode]) -> some View {
        VStack(spacing: 0) {
            ForEach(episodes) { episode in
                EpisodeRowView(episode: episode)
                if episode.id != episodes.last?.id {
                    Divider().padding(.leading, 14)
                }
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
