//
//  RMUnavailableContent.swift
//  Rickipedia
//
//  Created by Rai Gross on 4/17/26.
//

enum RMUnavailableContent {
    case idle
    case notFound(String)
    case error(String)

    var title: String {
        switch self {
        case .idle: "Search the multiverse"
        case .notFound: "No characters found"
        case .error: "Search failed"
        }
    }

    var systemImage: String {
        switch self {
        case .idle: "magnifyingglass"
        case .notFound: "person.crop.circle.badge.questionmark"
        case .error: "wifi.exclamationmark"
        }
    }

    var description: String {
        switch self {
        case .idle: "Type at least two letters to find a character."
        case let .notFound(message): message
        case let .error(message): message
        }
    }
}
