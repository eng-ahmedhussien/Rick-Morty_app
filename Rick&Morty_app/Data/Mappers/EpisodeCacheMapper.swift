//
//  EpisodeCacheMapper.swift
//  EpisodeCacheMapper
//
//  Created by Ahmed on 10/09/2026.
//

import Foundation

enum EpisodeCacheMapper {
    static func toCached(_ episode: Episode) -> CachedEpisode {
        CachedEpisode(id: episode.id, name: episode.name, airDate: episode.airDate, code: episode.code)
    }

    static func toDomain(_ cached: CachedEpisode) -> Episode {
        Episode(id: cached.id, name: cached.name, airDate: cached.airDate, code: cached.code)
    }
}
