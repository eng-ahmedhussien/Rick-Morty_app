//
//  CharacterRowView.swift
//  CharacterRowView
//
//  Created by Ahmed on 11/09/2026.
//

import SwiftUI

struct CharacterRowView: View {
    let character: Character

    var body: some View {
        HStack(spacing: 12) {
            RemoteImageView(url: character.imageURL)
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(.headline)
                    .lineLimit(1)
                Text(character.species)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                StatusBadgeView(status: character.status)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(character.name), \(character.species), \(character.status.rawValue.capitalized)"
        )
    }
}
