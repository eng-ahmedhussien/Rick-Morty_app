//
//  StatusBadgeView.swift
//  StatusBadgeView
//
//  Created by Ahmed on 11/09/2026.
//

import SwiftUI


struct StatusBadgeView: View {
    let status: CharacterStatus

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(status.rawValue.capitalized)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Status: \(status.rawValue.capitalized)")
    }

    private var color: Color {
        switch status {
        case .alive: return .green
        case .dead: return .red
        case .unknown: return .gray
        }
    }
}
