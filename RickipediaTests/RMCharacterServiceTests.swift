//
//  RMCharacterServiceTests.swift
//  Rickipedia
//

@testable import Rickipedia
import XCTest

@MainActor
final class RMCharacterServiceTests: XCTestCase {
    // MARK: - Helpers

    private struct MockHTTPClient: RMHTTPClienting {
        let data: Data
        let statusCode: Int

        func responseData(for request: URLRequest) async throws -> (Data, URLResponse) {
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            return (data, response)
        }
    }

    private func makeService(data: Data, statusCode: Int = 200) -> RMCharacterService {
        RMCharacterService(
            httpClient: MockHTTPClient(data: data, statusCode: statusCode),
            rateLimitConfiguration: .disabled
        )
    }

    private func jsonData(named name: String) throws -> Data {
        let thisFile = URL(filePath: #filePath)
        let url = thisFile
            .deletingLastPathComponent()
            .appending(path: "json/\(name).json")
        return try Data(contentsOf: url)
    }

    // MARK: - fetchCharacters — success

    func testFetchCharacters_200_decodesResultCount() async throws {
        let data = try jsonData(named: "searchResponse")
        let response = try await makeService(data: data).fetchCharacters(from: XCTUnwrap(URL(string: "https://test.com")))
        XCTAssertEqual(response.results?.count, 20)
    }

    func testFetchCharacters_200_firstCharacterIsCorrect() async throws {
        let data = try jsonData(named: "searchResponse")
        let response = try await makeService(data: data).fetchCharacters(from: XCTUnwrap(URL(string: "https://test.com")))
        let first = try XCTUnwrap(response.results?.first)
        XCTAssertEqual(first.id, 1)
        XCTAssertEqual(first.name, "Rick Sanchez")
    }

    func testFetchCharacters_200_emptyTypeDecodedAsNil() async throws {
        let data = try jsonData(named: "searchResponse")
        let response = try await makeService(data: data).fetchCharacters(from: XCTUnwrap(URL(string: "https://test.com")))
        let rick = try XCTUnwrap(response.results?.first(where: { $0.id == 1 }))
        XCTAssertNil(rick.type)
    }

    func testFetchCharacters_200_nonEmptyTypeIsPreserved() async throws {
        let data = try jsonData(named: "searchResponse")
        let response = try await makeService(data: data).fetchCharacters(from: XCTUnwrap(URL(string: "https://test.com")))
        let antennaRick = try XCTUnwrap(response.results?.first(where: { $0.id == 19 }))
        XCTAssertEqual(antennaRick.type, "Human with antennae")
    }

    func testFetchCharacters_200_infoNextIsSet() async throws {
        let data = try jsonData(named: "searchResponse")
        let response = try await makeService(data: data).fetchCharacters(from: XCTUnwrap(URL(string: "https://test.com")))
        XCTAssertNotNil(response.info?.next)
    }

    // MARK: - fetchCharacters — errors

    func testFetchCharacters_404_throwsNotFound() async throws {
        let data = try jsonData(named: "errorResponse")
        let service = makeService(data: data, statusCode: 404)
        do {
            _ = try await service.fetchCharacters(from: XCTUnwrap(URL(string: "https://test.com")))
            XCTFail("Expected NetworkError.notFound")
        } catch {
            XCTAssertEqual(error as? NetworkError, .notFound)
        }
    }
}
