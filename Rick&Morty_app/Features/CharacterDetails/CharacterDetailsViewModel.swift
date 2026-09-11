import Foundation

@MainActor
@Observable
final class CharacterDetailsViewModel {

    enum EpisodesState: Equatable {
        case idle
        case loading
        case loaded([Episode])
        case error(String)
    }

    let character: Character
    private(set) var episodesState: EpisodesState = .idle

    private let episodeRepository: EpisodeRepositoryProtocol

    init(character: Character, episodeRepository: EpisodeRepositoryProtocol) {
        self.character = character
        self.episodeRepository = episodeRepository
    }

    func loadEpisodesIfNeeded() async {
        guard episodesState == .idle else { return }
        await loadEpisodes()
    }

    func retry() async {
        await loadEpisodes()
    }

    private func loadEpisodes() async {
        guard !character.episodeIDs.isEmpty else {
            episodesState = .loaded([])
            return
        }

        episodesState = .loading
        do {
            let episodes = try await episodeRepository.fetchEpisodes(ids: character.episodeIDs)
            episodesState = .loaded(episodes)
        } catch {
            episodesState = .error(Self.describe(error))
        }
    }

    private static func describe(_ error: Error) -> String {
        if let network = error as? NetworkError {
            return network.errorDescription ?? "Something went wrong."
        }
        return error.localizedDescription
    }
}
