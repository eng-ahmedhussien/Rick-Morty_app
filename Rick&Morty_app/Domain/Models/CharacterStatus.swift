//
//  CharacterStatus.swift
//  CharacterStatus
//
//  Created by Ahmed on 10/09/2026.
//

import Foundation

enum CharacterStatus: String, CaseIterable, Identifiable, Sendable {
    case alive = "Alive"
    case dead = "Dead"
    case unknown = "unknown"
    
    var id: String { rawValue }
}
