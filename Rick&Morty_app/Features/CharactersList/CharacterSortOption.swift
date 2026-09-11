//
//  CharacterSortOption.swift
//  CharacterSortOption
//
//  Created by Ahmed on 11/09/2026.
//

import Foundation


enum CharacterSortOption: String, CaseIterable, Identifiable {
    case none
    case nameAscending
    case nameDescending

    var id: String { rawValue }

    var label: String {
        switch self {
        case .none: return "Default"
        case .nameAscending: return "Name A–Z"
        case .nameDescending: return "Name Z–A"
        }
    }

    func apply(to characters: [Character]) -> [Character] {
        switch self {
        case .none:
            return characters
        case .nameAscending:
            return characters.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .nameDescending:
            return characters.sorted { $0.name.localizedCompare($1.name) == .orderedDescending }
        }
    }
}
