//
//  Item.swift
//  Rick&Morty_app
//
//  Created by Ahmed on 09/09/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
