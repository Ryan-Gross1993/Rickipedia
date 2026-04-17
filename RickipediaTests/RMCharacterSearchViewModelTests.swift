//
//  RMCharacterSearchViewModelTests.swift
//  Rickipedia
//

@testable import Rickipedia
import XCTest

@MainActor
final class RMCharacterSearchViewModelTests: XCTestCase {
    // MARK: - Mock

    final class MockCharacterService: RMCharacterServicable {
        var responses: [Result<RMCharacterSearchResponse, Error>] = []
        private(set) var fetchCallCount = 0

        func searchURL(for query: String) throws -> URL {
            URL(string: "https://test.com/api/character?name=\(query)")!
        }

        func fetchCharacters(from _: URL) async throws -> RMCharacterSearchResponse {
            fetchCallCount += 1
            guard !responses.isEmpty else { throw NetworkError.invalidResponse }
            return try responses.removeFirst().get()
        }
    }

    // MARK: - Helpers

    private var mock: MockCharacterService!
    private var viewModel: RMCharacterSearchViewModel!

    override func setUp() {
        super.setUp()
        mock = MockCharacterService()
        viewModel = RMCharacterSearchViewModel(mock)
    }

    private func makeCharacter(id: Int) -> RMCharacterSearchResponse.RMCharacter {
        .init(
            id: id,
            name: "Character \(id)",
            status: "Alive",
            species: "Human",
            gender: "Male",
            origin: .init(name: "Earth", url: nil),
            image: URL(string: "https://example.com/\(id).jpg")!,
            created: Date()
        )
    }

    private func makeResponse(
        results: [RMCharacterSearchResponse.RMCharacter],
        next: String? = nil
    ) -> RMCharacterSearchResponse {
        RMCharacterSearchResponse(
            info: .init(count: results.count, pages: 1, next: next, prev: nil),
            results: results,
            error: nil
        )
    }

    // MARK: - query

    func testQuery_emptyText_setsIdleState() async {
        await viewModel.query(searchText: "")
        guard case .idle = viewModel.state else {
            return XCTFail("Expected .idle, got \(viewModel.state)")
        }
    }

    func testQuery_singleCharacter_setsEmptyState() async {
        await viewModel.query(searchText: "R")
        guard case .empty = viewModel.state else {
            return XCTFail("Expected .empty, got \(viewModel.state)")
        }
    }

    func testQuery_success_setsLoadedStateWithResults() async {
        let characters = (1 ... 3).map { makeCharacter(id: $0) }
        mock.responses = [.success(makeResponse(results: characters))]

        await viewModel.query(searchText: "Rick")

        guard case let .loaded(response) = viewModel.state else {
            return XCTFail("Expected .loaded, got \(viewModel.state)")
        }
        XCTAssertEqual(response.results?.count, 3)
    }

    func testQuery_notFound_setsNotFoundState() async {
        mock.responses = [.failure(NetworkError.notFound)]

        await viewModel.query(searchText: "xyzzy")

        guard case .notFound = viewModel.state else {
            XCTFail("Expected .notFound, got \(viewModel.state)")
            return
        }
    }

    func testQuery_notFoundCached_doesNotFetchAgain() async {
        mock.responses = [.failure(NetworkError.notFound), .failure(NetworkError.notFound)]

        await viewModel.query(searchText: "xyzzy")
        await viewModel.query(searchText: "xyzzy")

        XCTAssertEqual(mock.fetchCallCount, 1)
    }

    func testQuery_cacheHit_doesNotFetchAgain() async {
        let characters = [makeCharacter(id: 1)]
        mock.responses = [.success(makeResponse(results: characters))]

        await viewModel.query(searchText: "Rick")
        await viewModel.query(searchText: "Rick")

        XCTAssertEqual(mock.fetchCallCount, 1)
    }

    // MARK: - loadNextPage

    func testLoadNextPage_combinesResultsInOrder() async {
        let page1 = (1 ... 3).map { makeCharacter(id: $0) }
        let page2 = (4 ... 6).map { makeCharacter(id: $0) }

        mock.responses = [
            .success(makeResponse(results: page1, next: "https://test.com/page2")),
            .success(makeResponse(results: page2)),
        ]

        await viewModel.query(searchText: "Rick")
        await viewModel.loadNextPage()

        guard case let .loaded(response) = viewModel.state else {
            return XCTFail("Expected .loaded, got \(viewModel.state)")
        }
        XCTAssertEqual(response.results?.map(\.id), [1, 2, 3, 4, 5, 6])
    }

    func testLoadNextPage_noNextPage_doesNotFetch() async {
        let characters = [makeCharacter(id: 1)]
        mock.responses = [.success(makeResponse(results: characters, next: nil))]

        await viewModel.query(searchText: "Rick")
        await viewModel.loadNextPage()

        XCTAssertEqual(mock.fetchCallCount, 1)
    }

    // MARK: - loadNextPageIfNeeded

    func testLoadNextPageIfNeeded_itemBeforeThreshold_doesNotLoad() async {
        let characters = (1 ... 15).map { makeCharacter(id: $0) }
        mock.responses = [.success(makeResponse(results: characters, next: "https://test.com/page2"))]

        await viewModel.query(searchText: "Rick")
        await viewModel.loadNextPageIfNeeded(currentItem: characters[0])

        XCTAssertEqual(mock.fetchCallCount, 1)
    }

    func testLoadNextPageIfNeeded_itemAtThreshold_loads() async {
        let characters = (1 ... 15).map { makeCharacter(id: $0) }
        mock.responses = [
            .success(makeResponse(results: characters, next: "https://test.com/page2")),
            .success(makeResponse(results: [makeCharacter(id: 99)])),
        ]

        await viewModel.query(searchText: "Rick")
        await viewModel.loadNextPageIfNeeded(currentItem: characters[14])

        XCTAssertEqual(mock.fetchCallCount, 2)
    }
}
