//
//  EpisodeMapper.swift
//  EpisodeMapper
//
//  Created by Ahmed on 10/09/2026.
//

import Foundation

enum EpisodeMapper {
    static func map(_ dto: EpisodeDTO) -> Episode {
        Episode(id: dto.id, name: dto.name, airDate: dto.airDate, code: dto.episode)
    }
}
