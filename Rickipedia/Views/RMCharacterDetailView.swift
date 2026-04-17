//
//  RMCharacterDetailView.swift
//  Rickipedia
//
//  Created by Rai Gross on 4/17/26.
//

import NukeUI
import SwiftUI

struct RMCharacterDetailView: View {
    let character: RMCharacterSearchResponse.RMCharacter

    var image: some View {
        LazyImage(url: character.image) { state in
            if let img = state.image {
                img.resizable().scaledToFill()
            } else if state.error != nil {
                Color(uiColor: .secondarySystemBackground)
                    .overlay {
                        Image(systemName: "person.crop.circle")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
            } else {
                Color(uiColor: .secondarySystemBackground)
                    .overlay {
                        ProgressView()
                    }
            }
        }
        .pipeline(.rateLimited)
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
    }

    var details: some View {
        ViewThatFits(in: .vertical) {
            VStack(alignment: .leading, spacing: 4) {
                RMCharacterDetailRow(label: "Species", value: character.species)
                RMCharacterDetailRow(label: "Status", value: character.status)
                RMCharacterDetailRow(label: "Origin", value: character.origin.name)

                if let type = character.type {
                    RMCharacterDetailRow(label: "Type", value: type)
                }

                RMCharacterDetailRow(label: "First seen", value: character.created.formatted(date: .long, time: .omitted))
            }
        }
    }

    var body: some View {
        ScrollView {
            image
            details
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .background(Color.rmBackground.ignoresSafeArea())
        .navigationTitle(character.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.rmBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
