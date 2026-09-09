//
//  HTTPHeader.swift
//  HTTPHeader
//
//  Created by Ahmed on 09/09/2026.
//

import Foundation

enum HTTPHeader: Sendable {
    case `default`
    case custom([String: String])

    var values: [String: String] {
        switch self {
        case .default:
            return HTTPHeader.defaultValues
        case .custom(let headers):
            return HTTPHeader.defaultValues.merging(headers) { _, new in new }
        }
    }

    private static var defaultValues: [String: String] {
        ["Accept": "application/json"]
    }
}
