//
//  SearchState.swift
//  Rickipedia
//
//  Created by Rai Gross on 4/17/26.
//

enum SearchState<Response> {
    case idle
    case loading
    case loaded(Response)
    case empty
    case notFound(String)
    case error(String)

    var message: String? {
        switch self {
        case .idle:
            "Search by character name."
        case .loading:
            nil
        case .loaded:
            nil
        case .empty:
            "No characters matched that name."
        case let .notFound(searchText):
            "No characters found for \"\(searchText)\"."
        case let .error(message):
            message
        }
    }
}
