//
//  EpisodeRepository.swift
//  EpisodeRepository
//
//  Created by Ahmed on 10/09/2026.
//

import Foundation

struct CharacterFilter: Sendable, Equatable {
    var searchText: String = ""
    var status: CharacterStatus?

    static let none = CharacterFilter()
}
