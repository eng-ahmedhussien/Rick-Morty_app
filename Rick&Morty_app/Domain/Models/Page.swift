//
//  Page.swift
//  Page
//
//  Created by Ahmed on 10/09/2026.
//

import Foundation

struct Page<Element: Sendable>: Sendable {
    let items: [Element]
    let hasNextPage: Bool
}
