import Foundation
import Testing
@testable import Rick_Morty_app

@Suite
struct CharacterCacheMapperTests {
    @Test func roundTripsThroughCache() {
        let original = Fixtures.character(
            id: 5,
            name: "Birdperson",
            status: .dead,
            species: "Bird-Person",
            type: "Superhero",
            gender: .male,
            imageURL: URL(string: "https://example.com/5.png"),
            originName: "Bird World",
            locationName: "Bird World",
            episodeIDs: [3, 7]
        )

        let restored = CharacterCacheMapper.toDomain(CharacterCacheMapper.toCached(original))

        #expect(restored == original)
    }

    @Test func fallsBackToUnknownForCorruptedRawValues() {
        let cached = CachedCharacter(
            id: 1,
            name: "Test",
            statusRaw: "not-a-status",
            species: "Human",
            type: nil,
            genderRaw: "not-a-gender",
            imageURLString: nil,
            originName: "Earth",
            locationName: "Earth",
            episodeIDs: []
        )

        let restored = CharacterCacheMapper.toDomain(cached)

        #expect(restored.status == .unknown)
        #expect(restored.gender == .unknown)
        #expect(restored.imageURL == nil)
    }
}
