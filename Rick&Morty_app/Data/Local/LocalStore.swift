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

    func cacheCharacters(_ characters: [Character]) throws {
        for character in characters {
            modelContext.insert(CharacterCacheMapper.toCached(character))
        }
        try modelContext.save()
    }

    func cachedCharacters(matching filter: CharacterFilter) throws -> [Character] {
        let searchText = filter.searchText
        let hasSearch = !searchText.isEmpty
        let hasStatus = filter.status != nil
        let statusRaw = filter.status?.rawValue ?? ""

        let predicate = #Predicate<CachedCharacter> { character in
            (!hasSearch || character.name.localizedStandardContains(searchText))
                && (!hasStatus || character.statusRaw == statusRaw)
        }
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.id)])
        return try modelContext.fetch(descriptor).map(CharacterCacheMapper.toDomain)
    }

    // MARK: - Episodes

    func cacheEpisodes(_ episodes: [Episode]) throws {
        for episode in episodes {
            modelContext.insert(EpisodeCacheMapper.toCached(episode))
        }
        try modelContext.save()
    }

    func cachedEpisodes(ids: [Int]) throws -> [Episode] {
        guard !ids.isEmpty else { return [] }
        let descriptor = FetchDescriptor<CachedEpisode>(
            predicate: #Predicate { ids.contains($0.id) },
            sortBy: [SortDescriptor(\.id)]
        )
        return try modelContext.fetch(descriptor).map(EpisodeCacheMapper.toDomain)
    }
}
