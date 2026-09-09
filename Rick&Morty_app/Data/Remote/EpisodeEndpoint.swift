import Foundation

/// `GET /episode/{id}` for one id, `GET /episode/{id},{id},...}` for many —
/// same path shape either way. The response shape differs (single object
/// vs. array), which `EpisodeRemoteDataSource` handles at the decode step.
enum EpisodeEndpoint: Endpoint {
    case episodes(ids: [Int])

    var path: String {
        switch self {
        case .episodes(let ids):
            return "episode/\(ids.map(String.init).joined(separator: ","))"
        }
    }
}
