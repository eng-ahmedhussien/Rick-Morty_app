//
//  EpisodeRepository.swift
//  EpisodeRepository
//
//  Created by Ahmed on 10/09/2026.
//

import Foundation
import SwiftData

@Model
final class CachedEpisode {
    @Attribute(.unique) var id: Int
    var name: String
    var airDate: String
    var code: String

    init(id: Int, name: String, airDate: String, code: String) {
        self.id = id
        self.name = name
        self.airDate = airDate
        self.code = code
    }
}
