//
//  EpisodeDTO.swift
//  EpisodeDTO
//
//  Created by Ahmed on 10/09/2026.
//

import Foundation

struct EpisodeDTO: Decodable, Sendable {
    let id: Int
    let name: String
    let airDate: String
    let episode: String
    let characters: [String]
    let url: String
    let created: String
}
