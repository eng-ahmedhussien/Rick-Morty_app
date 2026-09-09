//
//  Character.swift
//  Character
//
//  Created by Ahmed on 10/09/2026.
//

import Foundation


struct Character: Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let status: CharacterStatus
    let species: String
    let type: String?
    let gender: CharacterGender
    let imageURL: URL?
    let originName: String
    let locationName: String
    let episodeIDs: [Int]
}
