//
//  NetworkError.swift
//  Rickipedia
//
//  Created by Rai Gross on 4/17/26.
//

import Foundation

enum NetworkError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case notFound
    case rateLimited
    case serverError(statusCode: Int)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "The character search URL could not be built."
        case .invalidResponse:
            "The character search returned an unexpected response."
        case .notFound:
            "No characters matched that name."
        case .rateLimited:
            "The character search is busy. Please wait a moment and try again."
        case let .serverError(statusCode):
            "The character search failed with status code \(statusCode)."
        case .decodingFailed:
            "The character search response could not be read."
        }
    }
}
