import Foundation
@testable import Rick_Morty_app

/// Shared test data builders. Every parameter has a sensible default so
/// call sites only spell out the fields a given test actually cares about.
enum Fixtures {
    static func characterDTO(
        id: Int = 1,
        name: String = "Rick Sanchez",
        status: String = "Alive",
        species: String = "Human",
        type: String = "",
        gender: String = "Male",
        originName: String = "Earth",
        locationName: String = "Earth",
        image: String = "https://example.com/1.png",
        episodeURLs: [String] = ["https://rickandmortyapi.com/api/episode/1"]
    ) -> CharacterDTO {
        CharacterDTO(
            id: id,
            name: name,
            status: status,
            species: species,
            type: type,
            gender: gender,
            origin: NamedResourceDTO(name: originName, url: ""),
            location: NamedResourceDTO(name: locationName, url: ""),
            image: image,
            episode: episodeURLs,
            url: "",
            created: ""
        )
    }

    static func character(
        id: Int = 1,
        name: String = "Rick Sanchez",
        status: CharacterStatus = .alive,
        species: String = "Human",
        type: String? = nil,
        gender: CharacterGender = .male,
        imageURL: URL? = URL(string: "https://example.com/1.png"),
        originName: String = "Earth",
        locationName: String = "Earth",
        episodeIDs: [Int] = [1]
    ) -> Character {
        Character(
            id: id,
            name: name,
            status: status,
            species: species,
            type: type,
            gender: gender,
            imageURL: imageURL,
            originName: originName,
            locationName: locationName,
            episodeIDs: episodeIDs
        )
    }

    static func episodeDTO(
        id: Int = 1,
        name: String = "Pilot",
        airDate: String = "December 2, 2013",
        code: String = "S01E01"
    ) -> EpisodeDTO {
        EpisodeDTO(id: id, name: name, airDate: airDate, episode: code, characters: [], url: "", created: "")
    }

    static func episode(
        id: Int = 1,
        name: String = "Pilot",
        airDate: String = "December 2, 2013",
        code: String = "S01E01"
    ) -> Episode {
        Episode(id: id, name: name, airDate: airDate, code: code)
    }
}
