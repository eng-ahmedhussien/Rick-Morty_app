//
//  CharacterRepository.swift
//  CharacterRepository
//
//  Created by Ahmed on 10/09/2026.
//

import Foundation

struct CharacterRepository: CharacterRepositoryProtocol {
    let remoteDataSource: CharacterRemoteDataSource
    let localStore: LocalStore

    func fetchCharacters(page: Int, filter: CharacterFilter) async throws -> Page<Character> {
        do {
            let response = try await remoteDataSource.fetchCharacters(page: page, filter: filter)
            let characters = response.results.map(CharacterMapper.map)

            try? await localStore.cacheCharacters(characters)
            return Page(items: characters, hasNextPage: response.info.next != nil)
        } catch NetworkError.notFound {
            /// 404  mean "this filter matched nothing" —
            /// that's an empty result, not a failure.
            return Page(items: [], hasNextPage: false)
        } catch {
            /// Any other failure (offline, timeout, server error, ...) falls
            /// read from cash with filter
            let cached = try await localStore.cachedCharacters(matching: filter)
            guard !cached.isEmpty else { throw error }
            return Page(items: cached, hasNextPage: false)
        }
    }
}
