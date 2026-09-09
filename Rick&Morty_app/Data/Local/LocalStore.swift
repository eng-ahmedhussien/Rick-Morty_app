//
//  LocalStore.swift
//  LocalStore
//
//  Created by Ahmed on 10/09/2026.
//

import Foundation
import SwiftData

@ModelActor
actor LocalStore {

    // MARK: - Characters

    // Write-through cache update: inserts characters that aren't stored
    // yet, updates in place the ones that are.
    func upsertCharacters(_ characters: [Character]) throws {
        for character in characters {
            let id = character.id
            let descriptor = FetchDescriptor<CachedCharacter>(predicate: #Predicate { $0.id == id })
            if let existing = try modelContext.fetch(descriptor).first {
                CharacterCacheMapper.update(existing, with: character)
            } else {
                modelContext.insert(CharacterCacheMapper.toCached(character))
            }
        }
        try modelContext.save()
    }

    // Every cached character matching `filter`. Used as the offline
    // fallback when the network request fails — see `CharacterRepository`.
    func cachedCharacters(matching filter: CharacterFilter) throws -> [Character] {
        let descriptor = FetchDescriptor<CachedCharacter>(sortBy: [SortDescriptor(\.id)])
        let all = try modelContext.fetch(descriptor).map(CharacterCacheMapper.toDomain)
        return all.filter { character in
            let matchesName = filter.searchText.isEmpty
                || character.name.localizedCaseInsensitiveContains(filter.searchText)
            let matchesStatus = filter.status == nil || character.status == filter.status
            return matchesName && matchesStatus
        }
    }

    // MARK: - Episodes

    // Episodes are immutable on the API side, so unlike characters this
    // only inserts — a cached episode never needs updating.
    func upsertEpisodes(_ episodes: [Episode]) throws {
        for episode in episodes {
            let id = episode.id
            let descriptor = FetchDescriptor<CachedEpisode>(predicate: #Predicate { $0.id == id })
            if try modelContext.fetch(descriptor).first == nil {
                modelContext.insert(EpisodeCacheMapper.toCached(episode))
            }
        }
        try modelContext.save()
    }

    func cachedEpisodes(ids: [Int]) throws -> [Episode] {
        let descriptor = FetchDescriptor<CachedEpisode>(predicate: #Predicate { ids.contains($0.id) })
        return try modelContext.fetch(descriptor).map(EpisodeCacheMapper.toDomain)
    }
}
