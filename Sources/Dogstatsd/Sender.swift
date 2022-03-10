import Foundation

/// A dogstatsd sender interface.
public protocol StatsdSender {
    func sendRaw(metric: String)
}

extension StatsdSender {
    public func send(metric: DogstatsdMetric, tags: [String: String], rate: Float) {
        guard shouldSample(rate: rate) else {
            return
        }
        
        if tags.isEmpty {
            sendRaw(metric: metric.toWire)
            return
        }
            
        let wireTags = tags.reduce("#") { reduced, kv in
            "\(reduced)\(kv.key):\(kv.value),"
        }.dropLast()
        
        sendRaw(metric: "\(metric.toWire)|\(wireTags)")
    }
    
    private func shouldSample(rate: Float) -> Bool {
        if rate >= 1 {
            return true
        }
        return Float.random(in: 0..<1.0) < rate
    }
}

