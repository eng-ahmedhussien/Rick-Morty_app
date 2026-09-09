//
//  HTTPMethod.swift
//  HTTPMethod
//
//  Created by Ahmed on 09/09/2026.
//

import Foundation

enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
