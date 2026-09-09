//
//  EpisodeRepositoryProtocol.swift
//  EpisodeRepositoryProtocol
//
//  Created by Ahmed on 10/09/2026.
//

import Foundation

protocol EpisodeRepositoryProtocol: Sendable {
    func fetchEpisodes(ids: [Int]) async throws -> [Episode]
}
