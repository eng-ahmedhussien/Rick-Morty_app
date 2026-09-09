//
//  CharacterRepositoryProtocol.swift
//  CharacterRepositoryProtocol
//
//  Created by Ahmed on 10/09/2026.
//

import Foundation

protocol CharacterRepositoryProtocol: Sendable {
    func fetchCharacters(page: Int, filter: CharacterFilter) async throws -> Page<Character>
}
