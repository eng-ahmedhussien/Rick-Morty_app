//
//  EpisodeRepository.swift
//  EpisodeRepository
//
//  Created by Ahmed on 10/09/2026.
//

import Foundation

struct EpisodeRepository: EpisodeRepositoryProtocol {
    let remoteDataSource: EpisodeRemoteDataSource
    let localStore: LocalStore

    func fetchEpisodes(ids: [Int]) async throws -> [Episode] {
        guard !ids.isEmpty else { return [] }

        let cached = try await localStore.cachedEpisodes(ids: ids)
        let cachedIDs = Set(cached.map(\.id))
        let missingIDs = ids.filter { !cachedIDs.contains($0) }

        // Every episode already cached — no network call needed at all.
        guard !missingIDs.isEmpty else {
            return order(cached, by: ids)
        }

        do {
            let fetched = try await remoteDataSource.fetchEpisodes(ids: missingIDs).map(EpisodeMapper.map)
            try? await localStore.cacheEpisodes(fetched)
            return order(cached + fetched, by: ids)
        } catch {
            // Offline with a partial cache: show what's stored rather than
            // failing the whole episodes section over the missing ones.
            guard !cached.isEmpty else { throw error }
            return order(cached, by: ids)
        }
    }

    /// Restores the character's original episode order — `ids` may name
    /// episodes out of numeric order, and cache/network results don't
    /// preserve it on their own.
    private func order(_ episodes: [Episode], by ids: [Int]) -> [Episode] {
        let byID = Dictionary(uniqueKeysWithValues: episodes.map { ($0.id, $0) })
        return ids.compactMap { byID[$0] }
    }
}
