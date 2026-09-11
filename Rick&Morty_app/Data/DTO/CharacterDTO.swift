//
//  CharacterDTO.swift
//  CharacterDTO
//
//  Created by Ahmed on 10/09/2026.
//

import Foundation

struct CharacterDTO: Decodable, Sendable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let origin: NamedResourceDTO
    let location: NamedResourceDTO
    let image: String
    let episode: [String]
    let url: String
    let created: String
}
