//
//  RMCharacterGridImageView.swift
//  Rickipedia
//
//  Created by Rai Gross on 4/16/26.
//

import NukeUI
import SwiftUI

struct RMCharacterGridImageView: View {
    let imageUrl: URL
    let onPaginate: () async -> Void
    @State var isRetry = false

    var body: some View {
        LazyImage(url: imageUrl) { state in
            if let img = state.image {
                img.resizable()
                    .scaledToFill()
            } else if state.error != nil {
                RMImageRetryView()
                    .task {
                        try? await Task.sleep(for: .seconds(6))
                        isRetry.toggle()
                    }
            } else {
                ProgressView()
            }
        }
        .pipeline(.rateLimited)
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .clipped()
        .clipShape(.rect(cornerRadius: 15.0))
        .task {
            await onPaginate()
        }
        // Forces the re-render, so image tries to reload (R&M API rate-limits)
        .id(imageUrl.absoluteString + String(isRetry))
    }
}
