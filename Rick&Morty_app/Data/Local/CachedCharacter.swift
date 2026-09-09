//
//  CachedCharacter.swift
//  CachedCharacter
//
//  Created by Ahmed on 10/09/2026.
//

import Foundation
import SwiftData

@Model
final class CachedCharacter {
    @Attribute(.unique) var id: Int
    var name: String
    var statusRaw: String
    var species: String
    var type: String?
    var genderRaw: String
    var imageURLString: String?
    var originName: String
    var locationName: String
    var episodeIDs: [Int]
    var fetchedAt: Date

    init(
        id: Int,
        name: String,
        statusRaw: String,
        species: String,
        type: String?,
        genderRaw: String,
        imageURLString: String?,
        originName: String,
        locationName: String,
        episodeIDs: [Int],
        fetchedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.statusRaw = statusRaw
        self.species = species
        self.type = type
        self.genderRaw = genderRaw
        self.imageURLString = imageURLString
        self.originName = originName
        self.locationName = locationName
        self.episodeIDs = episodeIDs
        self.fetchedAt = fetchedAt
    }
}
