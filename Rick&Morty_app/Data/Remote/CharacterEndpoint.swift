import Foundation

enum CharacterEndpoint: Endpoint {
    case list(page: Int, filter: CharacterFilter)

    var path: String { "character" }

    var queryItems: [URLQueryItem] {
        switch self {
        case .list(let page, let filter):
            var items = [URLQueryItem(name: "page", value: String(page))]
            if !filter.searchText.isEmpty {
                items.append(URLQueryItem(name: "name", value: filter.searchText))
            }
            if let status = filter.status {
                ///The API expects lowercase values ("alive", "dead", "unknown").
                items.append(URLQueryItem(name: "status", value: status.rawValue.lowercased()))
            }
            return items
        }
    }
}
