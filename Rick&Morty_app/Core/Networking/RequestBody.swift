//
//  RequestBody.swift
//  RequestBody
//
//  Created by Ahmed on 09/09/2026.
//

import Foundation

enum RequestBody: Sendable {
    case none
    case json(AnyEncodableBody)

    static func json<T: Encodable & Sendable>(_ value: T) -> RequestBody {
        .json(AnyEncodableBody(value))
    }
}

struct AnyEncodableBody: Encodable, Sendable {
    private let encodeClosure: @Sendable (Encoder) throws -> Void

    init<T: Encodable & Sendable>(_ wrapped: T) {
        encodeClosure = { encoder in try wrapped.encode(to: encoder) }
    }

    func encode(to encoder: Encoder) throws {
        try encodeClosure(encoder)
    }
}
