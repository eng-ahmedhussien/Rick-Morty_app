//
//  RickAndMortyApp.swift
//  RickAndMortyApp
//
//  Created by Ahmed on 09/09/2026.
//

import SwiftUI

@main
struct RickAndMortyApp: App {
    @State private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            CharactersListScreen(
                characterRepository: container.characterRepository,
                episodeRepository: container.episodeRepository
            )
        }
    }
}
