//
//  Episode.swift
//  Episode
//
//  Created by Ahmed on 10/09/2026.
//

import Foundation

struct Episode: Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let airDate: String
    let code: String
}
