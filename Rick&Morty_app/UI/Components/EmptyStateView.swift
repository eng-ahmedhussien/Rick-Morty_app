//
//  EmptyStateView.swift
//  EmptyStateView
//
//  Created by Ahmed on 11/09/2026.
//

import SwiftUI

/// Shown when a load succeeds but returns nothing (e.g. a search with no
/// matches).
struct EmptyStateView: View {
    var title = "No Characters"
    var message = "No characters match your search."

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: "person.slash")
        } description: {
            Text(message)
        }
    }
}
