import Foundation
import Testing
@testable import Rick_Morty_app

@Suite
struct CharacterMapperTests {
    @Test func mapsKnownStatusAndGender() {
        let dto = Fixtures.characterDTO(status: "Dead", gender: "Female")
        let character = CharacterMapper.map(dto)
        #expect(character.status == .dead)
        #expect(character.gender == .female)
    }

    @Test func fallsBackToUnknownStatusForUnrecognizedValue() {
        let dto = Fixtures.characterDTO(status: "Weird")
        #expect(CharacterMapper.map(dto).status == .unknown)
    }

    @Test func fallsBackToUnknownGenderForUnrecognizedValue() {
        let dto = Fixtures.characterDTO(gender: "Weird")
        #expect(CharacterMapper.map(dto).gender == .unknown)
    }

    @Test func mapsEmptyTypeToNil() {
        let dto = Fixtures.characterDTO(type: "")
        #expect(CharacterMapper.map(dto).type == nil)
    }

    @Test func mapsNonEmptyType() {
        let dto = Fixtures.characterDTO(type: "Parasite")
        #expect(CharacterMapper.map(dto).type == "Parasite")
    }

    @Test func parsesEpisodeIDsFromURLs() {
        let dto = Fixtures.characterDTO(episodeURLs: [
            "https://rickandmortyapi.com/api/episode/1",
            "https://rickandmortyapi.com/api/episode/28"
        ])
        #expect(CharacterMapper.map(dto).episodeIDs == [1, 28])
    }

    @Test func ignoresMalformedEpisodeURLs() {
        let dto = Fixtures.characterDTO(episodeURLs: [
            "not-a-url",
            "https://rickandmortyapi.com/api/episode/5"
        ])
        #expect(CharacterMapper.map(dto).episodeIDs == [5])
    }

    @Test func mapsInvalidImageStringToNilURL() {
        let dto = Fixtures.characterDTO(image: "")
        #expect(CharacterMapper.map(dto).imageURL == nil)
    }
}
