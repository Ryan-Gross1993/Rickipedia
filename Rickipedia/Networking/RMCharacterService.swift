//
//  RMCharacterService.swift
//  Rickipedia
//
//  Created by Rai Gross on 4/16/26.
//

import Foundation

struct RMURLSessionHTTPClient: RMHTTPClienting {
    func responseData(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await URLSession.shared.data(for: request)
    }
}

final class RMCharacterService: RMCharacterServicable {
    private struct RateLimitedResponse: Error {
        let retryAfter: TimeInterval?
    }

    private let baseURL: String
    private let httpClient: any RMHTTPClienting
    private let decoder: JSONDecoder
    private let rateLimitConfiguration: RMRateLimitConfiguration
    private let rateLimiter: RMRequestRateLimiter

    init(baseURL: String = "https://rickandmortyapi.com/api/character/",
         httpClient: any RMHTTPClienting = RMURLSessionHTTPClient(),
         decoder: JSONDecoder = JSONDecoder(),
         rateLimitConfiguration: RMRateLimitConfiguration = .standard)
    {
        self.baseURL = baseURL
        self.httpClient = httpClient
        self.decoder = decoder
        self.rateLimitConfiguration = rateLimitConfiguration
        rateLimiter = RMRequestRateLimiter(
            minimumDelayBetweenRequests: rateLimitConfiguration.minimumDelayBetweenRequests
        )
    }

    func searchURL(for searchText: String) throws -> URL {
        let searchTerm = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !searchTerm.isEmpty else {
            throw NetworkError.invalidURL
        }

        guard var components = URLComponents(string: baseURL) else {
            throw NetworkError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "name", value: searchTerm),
        ]

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        return url
    }

    func fetchCharacters(from url: URL) async throws -> RMCharacterSearchResponse {
        var retryCount = 0

        while true {
            try await rateLimiter.waitForTurn()

            do {
                return try await performFetch(from: url)
            } catch let rateLimitError as RateLimitedResponse {
                guard retryCount < rateLimitConfiguration.maximumRetryCount else {
                    throw NetworkError.rateLimited
                }

                retryCount += 1

                let retryDelay = max(
                    rateLimitConfiguration.retryDelay * Double(retryCount),
                    rateLimitError.retryAfter ?? 0
                )

                try await rateLimiter.backOff(for: retryDelay)
            }
        }
    }

    private func performFetch(from url: URL) async throws -> RMCharacterSearchResponse {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await httpClient.responseData(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            do {
                return try decoder.decode(RMCharacterSearchResponse.self, from: data)
            } catch {
                throw NetworkError.decodingFailed
            }
        case 404:
            throw NetworkError.notFound
        case 429:
            throw RateLimitedResponse(retryAfter: retryAfterDelay(from: httpResponse))
        default:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
    }

    private func retryAfterDelay(from response: HTTPURLResponse) -> TimeInterval? {
        guard let retryAfter = response.value(forHTTPHeaderField: "Retry-After") else {
            return nil
        }

        return TimeInterval(retryAfter)
    }
}
