//
//  CharacterMapper.swift
//  CharacterMapper
//
//  Created by Ahmed on 10/09/2026.
//

import Foundation

enum CharacterMapper {
    static func map(_ dto: CharacterDTO) -> Character {
        Character(
            id: dto.id,
            name: dto.name,
            status: CharacterStatus(rawValue: dto.status) ?? .unknown,
            species: dto.species,
            type: dto.type.isEmpty ? nil : dto.type,
            gender: CharacterGender(rawValue: dto.gender) ?? .unknown,
            imageURL: URL(string: dto.image),
            originName: dto.origin.name,
            locationName: dto.location.name,
            episodeIDs: dto.episode.compactMap(Self.episodeID(from:))
        )
    }

    /// Pulls the trailing integer id off a resource URL, e.g.
    /// "https://rickandmortyapi.com/api/episode/28" -> 28.
    private static func episodeID(from urlString: String) -> Int? {
        guard let lastComponent = urlString.split(separator: "/").last else {
            return nil
        }
        return Int(lastComponent)
    }
}
