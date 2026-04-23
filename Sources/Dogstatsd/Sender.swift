/// Unless explicitly stated otherwise all files in this repository are licensed under the MIT License.
/// This product includes software developed at Datadog (https://www.datadoghq.com/)  Copyright 2022 Datadog, Inc.

import Foundation

/// A dogstatsd sender interface.
public protocol StatsdSender {
    var globalTags: [String] { get }
    
    func sendRaw(metric: String)
}

extension StatsdSender {
    public func send(metric: DogstatsdMetric, tags: [String], rate: Float) {
        guard shouldEmit(metric: metric, rate: rate) else {
            return
        }

        sendRaw(metric: metric.toWire(tags: globalTags + tags, rate: rate))
    }
    
    private func shouldEmit(metric: DogstatsdMetric, rate: Float) -> Bool {
        guard metric.supportsSampling else {
            return true
        }

        if rate >= 1 {
            return true
        }

        guard rate > 0 else {
            return false
        }

        return Float.random(in: 0..<1.0) < rate
    }
}
