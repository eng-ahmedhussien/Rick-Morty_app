import Foundation

/// `GET /episode/{id}` for one id, `GET /episode/{id},{id},...}` for many 
enum EpisodeEndpoint: Endpoint {
    case episodes(ids: [Int])

    var path: String {
        switch self {
        case .episodes(let ids):
            return "episode/\(ids.map(String.init).joined(separator: ","))"
        }
    }
}
