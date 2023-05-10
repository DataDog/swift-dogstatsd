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
        guard shouldSample(rate: rate) else {
            return
        }
        
        let allTags = globalTags + tags
        
        if allTags.isEmpty {
            sendRaw(metric: metric.toWire)
            return
        }
            
        let wireTags = "#\(allTags.joined(separator: ","))"
        sendRaw(metric: "\(metric.toWire)|\(wireTags)")
    }
    
    private func shouldSample(rate: Float) -> Bool {
        if rate >= 1 {
            return true
        }
        return Float.random(in: 0..<1.0) < rate
    }
}

