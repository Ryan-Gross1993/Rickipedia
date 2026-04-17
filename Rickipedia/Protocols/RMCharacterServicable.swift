//
//  RMCharacterServicable.swift
//  Rickipedia
//
//  Created by Rai Gross on 4/17/26.
//

import Foundation

protocol RMHTTPClienting {
    func responseData(for request: URLRequest) async throws -> (Data, URLResponse)
}

protocol RMCharacterServicable {
    func searchURL(for query: String) throws -> URL
    func fetchCharacters(from url: URL) async throws -> RMCharacterSearchResponse
}
