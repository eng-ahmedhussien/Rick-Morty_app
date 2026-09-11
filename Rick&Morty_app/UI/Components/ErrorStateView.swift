//
//  ErrorStateView.swift
//  ErrorStateView
//
//  Created by Ahmed on 11/09/2026.
//

import SwiftUI

/// Full-screen failure state with a retry action.
struct ErrorStateView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Something went wrong", systemImage: "wifi.exclamationmark")
        } description: {
            Text(message)
        } actions: {
            Button("Retry", action: retry)
                .buttonStyle(.borderedProminent)
        }
    }
}
