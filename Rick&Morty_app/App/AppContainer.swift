//
//  AppContainer.swift
//  AppContainer
//
//  Created by Ahmed on 11/09/2026.
//

import Foundation
import SwiftData

/// Composition root. Builds the object graph once at launch — the single
/// place that knows how repositories, the HTTP client, and the SwiftData
/// store fit together. Everything below this line receives its
/// dependencies through its initializer (constructor injection).

final class AppContainer {
    let characterRepository: CharacterRepositoryProtocol
    let episodeRepository: EpisodeRepositoryProtocol

    init() {
        let modelContainer: ModelContainer
        do {
            modelContainer = try ModelContainer(for: CachedCharacter.self, CachedEpisode.self)
        } catch {
            fatalError("Failed to create the SwiftData ModelContainer: \(error)")
        }

        let localStore = LocalStore(modelContainer: modelContainer)
        let httpClient = URLSessionHTTPClient()

        self.characterRepository = CharacterRepository(
            remoteDataSource: DefaultCharacterRemoteDataSource(httpClient: httpClient),
            localStore: localStore
        )
        self.episodeRepository = EpisodeRepository(
            remoteDataSource: DefaultEpisodeRemoteDataSource(httpClient: httpClient),
            localStore: localStore
        )
    }

    /// Injection point for previews and tests.
    init(
        characterRepository: CharacterRepositoryProtocol,
        episodeRepository: EpisodeRepositoryProtocol
    ) {
        self.characterRepository = characterRepository
        self.episodeRepository = episodeRepository
    }
}
