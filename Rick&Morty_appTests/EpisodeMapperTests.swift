import Foundation
import Testing
@testable import Rick_Morty_app

@Suite
struct EpisodeMapperTests {
    @Test func mapsAllFields() {
        let dto = Fixtures.episodeDTO(id: 10, name: "Total Rickall", airDate: "August 16, 2015", code: "S02E04")
        let episode = EpisodeMapper.map(dto)

        #expect(episode.id == 10)
        #expect(episode.name == "Total Rickall")
        #expect(episode.airDate == "August 16, 2015")
        #expect(episode.code == "S02E04")
    }
}
