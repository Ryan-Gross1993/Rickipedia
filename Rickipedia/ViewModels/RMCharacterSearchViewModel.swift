//
//  RMCharacterSearchViewModel.swift
//  Rickipedia
//
//  Created by Rai Gross on 4/16/26.
//

import Foundation

@MainActor
@Observable
final class RMCharacterSearchViewModel {
    var searchText = ""
    var state: SearchState<RMCharacterSearchResponse> = .idle
    var isLoadingNextPage = false

    private let service: any RMCharacterServicable
    private var responseCache: [String: RMCharacterSearchResponse] = [:]
    private var notFoundSearches: Set<String> = []
    private var activeSearchKey: String?

    init(_ service: RMCharacterServicable) {
        self.service = service
    }

    convenience init() {
        self.init(RMCharacterService())
    }

    func query(searchText: String) async {
        let searchTerm = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

//        guard searchTerm.count >= 2 else {
//            state = searchTerm.isEmpty ? .idle : .empty
//            return
//        }
        guard !searchTerm.isEmpty else {
            state = .empty
            return
        }

        let cacheKey = searchTerm.lowercased()

        if activeSearchKey == cacheKey {
            return
        }

        if notFoundSearches.contains(cacheKey) {
            state = .notFound(searchTerm)
            return
        }

        if let cachedResponse = responseCache[cacheKey] {
            apply(cachedResponse)
            return
        }

        activeSearchKey = cacheKey
        defer {
            if activeSearchKey == cacheKey {
                activeSearchKey = nil
            }
        }

        state = .loading

        do {
            let url = try service.searchURL(for: searchTerm)
            let response = try await service.fetchCharacters(from: url)
            guard !Task.isCancelled else { return }

            responseCache[cacheKey] = response
            apply(response)
        } catch NetworkError.notFound {
            guard !Task.isCancelled else { return }
            notFoundSearches.insert(cacheKey)
            state = .notFound(searchTerm)
        } catch is CancellationError {
            return
        } catch let urlError as URLError where urlError.code == .cancelled {
            return
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func loadNextPage() async {
        guard !isLoadingNextPage,
              case let .loaded(currentResponse) = state,
              let nextPage = currentResponse.info?.next,
              let nextURL = URL(string: nextPage)
        else {
            return
        }

        isLoadingNextPage = true
        defer { isLoadingNextPage = false }

        do {
            let nextResponse = try await service.fetchCharacters(from: nextURL)
            guard !Task.isCancelled else { return }

            var combinedResponse = nextResponse
            combinedResponse.results = (currentResponse.results ?? []) + (nextResponse.results ?? [])
            state = .loaded(combinedResponse)
            cacheCurrentSearchIfNeeded(combinedResponse)
        } catch is CancellationError {
            return
        } catch let urlError as URLError where urlError.code == .cancelled {
            return
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func loadNextPageIfNeeded(currentItem: RMCharacterSearchResponse.RMCharacter) async {
        guard case let .loaded(response) = state,
              let results = response.results,
              response.info?.next != nil,
              !isLoadingNextPage
        else {
            return
        }

        let thresholdIndex = results.index(
            results.endIndex,
            offsetBy: -10,
            limitedBy: results.startIndex
        ) ?? results.startIndex

        let thresholdItems = results[thresholdIndex...]

        if thresholdItems.contains(where: { $0.id == currentItem.id }) {
            await loadNextPage()
        }
    }

    private func apply(_ response: RMCharacterSearchResponse) {
        if let results = response.results, !results.isEmpty {
            state = .loaded(response)
        } else {
            state = .empty
        }
    }

    private func cacheCurrentSearchIfNeeded(_ response: RMCharacterSearchResponse) {
        let cacheKey = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !cacheKey.isEmpty else { return }

        responseCache[cacheKey] = response
    }
}
