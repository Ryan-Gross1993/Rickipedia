//
//  RMRequestRateLimiter.swift
//  Rickipedia
//
//  Created by Rai Gross on 4/17/26.
//

import Foundation

actor RMRequestRateLimiter {
    private let minimumDelayBetweenRequests: TimeInterval
    private var nextAvailableRequestDate = Date.distantPast

    init(minimumDelayBetweenRequests: TimeInterval) {
        self.minimumDelayBetweenRequests = minimumDelayBetweenRequests
    }

    func waitForTurn() async throws {
        let waitTime = nextAvailableRequestDate.timeIntervalSinceNow
        if waitTime > 0 {
            try await sleep(seconds: waitTime)
        }

        nextAvailableRequestDate = Date().addingTimeInterval(minimumDelayBetweenRequests)
    }

    func backOff(for seconds: TimeInterval) async throws {
        guard seconds > 0 else { return }

        let nextRetryDate = Date().addingTimeInterval(seconds)
        if nextRetryDate > nextAvailableRequestDate {
            nextAvailableRequestDate = nextRetryDate
        }

        try await sleep(seconds: seconds)
    }

    private func sleep(seconds: TimeInterval) async throws {
        guard seconds > 0 else { return }

        try await Task.sleep(for: .seconds(1))
    }
}
