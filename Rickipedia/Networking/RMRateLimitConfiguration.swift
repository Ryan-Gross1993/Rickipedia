//
//  RMRateLimitConfiguration.swift
//  Rickipedia
//
//  Created by Rai Gross on 4/17/26.
//

import SwiftUI

struct RMRateLimitConfiguration: Sendable {
    let minimumDelayBetweenRequests: TimeInterval
    let retryDelay: TimeInterval
    let maximumRetryCount: Int

    static let standard = RMRateLimitConfiguration(
        minimumDelayBetweenRequests: 0.25,
        retryDelay: 1.25,
        maximumRetryCount: 2
    )

    static let disabled = RMRateLimitConfiguration(
        minimumDelayBetweenRequests: 0,
        retryDelay: 0,
        maximumRetryCount: 0
    )
}
