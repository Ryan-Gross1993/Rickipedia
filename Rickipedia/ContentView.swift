//
//  ContentView.swift
//  Rickipedia
//
//  Created by Rai Gross on 4/14/26.
//

import NukeUI
import SwiftUI

struct ContentView: View {
    @State private var viewModel: RMCharacterSearchViewModel

    init() {
        viewModel = RMCharacterSearchViewModel()
    }

    init(viewModel: RMCharacterSearchViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            content
                .background(Color.rmBackground.ignoresSafeArea())
                .navigationTitle("Rickipedia")
                .toolbarBackground(Color.rmBackground, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .searchable(text: $viewModel.searchText, prompt: "Search characters")
                .task(id: viewModel.searchText) {
                    let searchText = viewModel.searchText
                    guard !searchText.isEmpty else {
                        await viewModel.query(searchText: searchText)
                        return
                    }

                    do {
                        try await Task.sleep(for: .milliseconds(450))
                    } catch {
                        return
                    }

                    await viewModel.query(searchText: searchText)
                }
                .onSubmit(of: .search) {
                    Task {
                        await viewModel.query(searchText: viewModel.searchText)
                    }
                }
                .navigationDestination(for: RMCharacterSearchResponse.RMCharacter.self) { character in
                    RMCharacterDetailView(character: character)
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            centeredState(content: {
                RMUnavailableView(content: .idle)
            })
        case .loading:
            centeredState {
                ProgressView("Searching characters...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        case let .loaded(response):
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100.0))]) {
                    ForEach(response.results ?? []) { character in
                        NavigationLink(value: character) {
                            RMCharacterGridImageView(imageUrl: character.image) {
                                Task {
                                    await viewModel.loadNextPageIfNeeded(currentItem: character)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal)
        case .empty, .notFound:
            centeredState {
                RMUnavailableView(content: .notFound(viewModel.state.message ?? "Try another name."))
            }
        case .error:
            centeredState {
                RMUnavailableView(content: .error(viewModel.state.message ?? "Try again in a moment."))
            }
        }
    }
}

private func centeredState<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    ZStack {
        content()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .ignoresSafeArea(.container, edges: .top)
}

#Preview {
    ContentView()
}
