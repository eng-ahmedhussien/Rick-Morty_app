//
//  RemoteImageView.swift
//  RemoteImageView
//
//  Created by Ahmed on 11/09/2026.
//

import NukeUI
import SwiftUI

struct RemoteImageView: View {
    let url: URL?
    var contentMode: ContentMode = .fill

    var body: some View {
        LazyImage(url: url) { state in
            if let image = state.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if state.error != nil {
                fallback(icon: "photo")
            } else {
                fallback(icon: nil)
            }
        }
    }

    @ViewBuilder
    private func fallback(icon: String?) -> some View {
        ZStack {
            Rectangle().fill(.quaternary)
            if let icon {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            } else {
                ProgressView()
            }
        }
    }
}
