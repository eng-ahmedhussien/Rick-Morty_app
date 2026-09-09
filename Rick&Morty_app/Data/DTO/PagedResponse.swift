//
//  PagedResponse.swift
//  PagedResponse
//
//  Created by Ahmed on 10/09/2026.
//

import Foundation

struct PagedResponse<Element: Decodable & Sendable>: Decodable, Sendable {
    let info: PageInfoDTO
    let results: [Element]
}

struct PageInfoDTO: Decodable, Sendable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}
