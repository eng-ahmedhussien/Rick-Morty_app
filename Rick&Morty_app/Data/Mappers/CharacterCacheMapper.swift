//
//  CharacterCacheMapper.swift
//  CharacterCacheMapper
//
//  Created by Ahmed on 90/09/2026.
//

import Foundation

enum CharacterCacheMapper {
    static func toCached(_ character: Character) -> CachedCharacter {
        CachedCharacter(
            id: character.id,
            name: character.name,
            statusRaw: character.status.rawValue,
            species: character.species,
            type: character.type,
            genderRaw: character.gender.rawValue,
            imageURLString: character.imageURL?.absoluteString,
            originName: character.originName,
            locationName: character.locationName,
            episodeIDs: character.episodeIDs
        )
    }

    static func toDomain(_ cached: CachedCharacter) -> Character {
        Character(
            id: cached.id,
            name: cached.name,
            status: CharacterStatus(rawValue: cached.statusRaw) ?? .unknown,
            species: cached.species,
            type: cached.type,
            gender: CharacterGender(rawValue: cached.genderRaw) ?? .unknown,
            imageURL: cached.imageURLString.flatMap(URL.init(string:)),
            originName: cached.originName,
            locationName: cached.locationName,
            episodeIDs: cached.episodeIDs
        )
    }

    /// Copies fresh field values onto an existing row in place, so a
    /// write-through update doesn't delete+reinsert and disturb SwiftData's
    /// identity tracking for that object.
    static func update(_ cached: CachedCharacter, with character: Character) {
        cached.name = character.name
        cached.statusRaw = character.status.rawValue
        cached.species = character.species
        cached.type = character.type
        cached.genderRaw = character.gender.rawValue
        cached.imageURLString = character.imageURL?.absoluteString
        cached.originName = character.originName
        cached.locationName = character.locationName
        cached.episodeIDs = character.episodeIDs
        cached.fetchedAt = .now
    }
}
