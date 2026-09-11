import Foundation
@testable import Rick_Morty_app

actor MockEpisodeRepository: EpisodeRepositoryProtocol {
    enum StubResult {
        case success([Episode])
        case failure(Error)
    }

    private var result: StubResult
    private(set) var requestedIDs: [[Int]] = []

    init(result: StubResult = .success([])) {
        self.result = result
    }

    func setResult(_ result: StubResult) {
        self.result = result
    }

    func fetchEpisodes(ids: [Int]) async throws -> [Episode] {
        requestedIDs.append(ids)
        switch result {
        case .success(let episodes): return episodes
        case .failure(let error): throw error
        }
    }
}
