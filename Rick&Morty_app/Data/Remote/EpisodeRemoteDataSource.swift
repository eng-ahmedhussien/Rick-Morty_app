import Foundation

protocol EpisodeRemoteDataSource: Sendable {
    func fetchEpisodes(ids: [Int]) async throws -> [EpisodeDTO]
}

struct DefaultEpisodeRemoteDataSource: EpisodeRemoteDataSource {
    let httpClient: HTTPClient

    func fetchEpisodes(ids: [Int]) async throws -> [EpisodeDTO] {
        guard !ids.isEmpty else { return [] }

        let endpoint = EpisodeEndpoint.episodes(ids: ids)
        if ids.count == 1 {
            // A single id returns one JSON object, not an array.
            let episode: EpisodeDTO = try await httpClient.send(endpoint)
            return [episode]
        }
        return try await httpClient.send(endpoint)
    }
}
