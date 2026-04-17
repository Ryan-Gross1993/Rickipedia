//
//  ImagePipeline.swift
//  Rickipedia
//
//  Created by Rai Gross on 4/16/26.
//

import Foundation
import Nuke

extension ImagePipeline {
    @MainActor
    static let rateLimited: ImagePipeline = {
        var config = ImagePipeline.Configuration()
        config.dataLoadingQueue.maxConcurrentOperationCount = 1

        config.dataLoader = DataLoader(configuration: {
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.waitsForConnectivity = true
            sessionConfig.timeoutIntervalForRequest = 30
            return sessionConfig
        }())

        return ImagePipeline(configuration: config)
    }()
}
