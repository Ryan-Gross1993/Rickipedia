//
//  RMCharacterSearchResponse.swift
//  Rickipedia
//
//  Created by Rai Gross on 4/16/26.
//

import Foundation

struct RMCharacterSearchResponse: Codable {
    struct ResponseInfo: Codable {
        let count: Int
        let pages: Int
        let next: String?
        let prev: String?
    }

    struct Origin: Codable, Hashable {
        let name: String
        let url: String?
    }

    struct RMCharacter: Codable, Hashable, Identifiable {
        let id: Int
        let name: String
        let status: String
        let species: String
        let type: String?
        let gender: String
        let origin: Origin
        let image: URL
        let created: Date

        private enum CodingKeys: String, CodingKey {
            case id, name, status, species, type, gender, origin, image, created
        }

        init(id: Int,
             name: String,
             status: String,
             species: String,
             type: String? = nil,
             gender: String,
             origin: Origin,
             image: URL,
             created: Date)
        {
            self.id = id
            self.name = name
            self.status = status
            self.species = species
            self.type = type
            self.gender = gender
            self.origin = origin
            self.image = image
            self.created = created
        }

        private static func makeISOFormatter() -> ISO8601DateFormatter {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return formatter
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(Int.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            status = try container.decode(String.self, forKey: .status)
            species = try container.decode(String.self, forKey: .species)
            gender = try container.decode(String.self, forKey: .gender)
            origin = try container.decode(Origin.self, forKey: .origin)
            image = try container.decode(URL.self, forKey: .image)

            let rawType = try container.decode(String.self, forKey: .type)
            type = rawType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : rawType

            let rawDate = try container.decode(String.self, forKey: .created)
            created = Self.makeISOFormatter().date(from: rawDate) ?? Date.now
        }
    }

    var info: ResponseInfo?
    var results: [RMCharacter]?
    var error: String?
}
