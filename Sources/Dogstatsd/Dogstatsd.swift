/// Unless explicitly stated otherwise all files in this repository are licensed under the MIT License.
/// This product includes software developed at Datadog (https://www.datadoghq.com/)  Copyright 2022 Datadog, Inc.

/// This file contains a complete, generic interface for dogstatsd.
/// You may implement a `StatsdSender` sender to support other frameworks.

import Foundation

public enum ServiceCheckStatus: Int {
    case ok, warn, critical, unknown
}

public enum EventPriority: String {
    case low, normal
}

public enum EventAlertType: String {
    case info, error, warning, success
}

public enum DogstatsdMetric {
    
    case count(name: String, value: Int64)
    case gauge(name: String, value: Float64)
    case histogram(name: String, value: Float64)
    case distribution(name: String, value: Float64)
    case set(name: String, value: String)
    case timing(name: String, value: TimeInterval)
    case serviceCheck(name: String, status: ServiceCheckStatus, timestamp: Date?, hostname: String?, message: String?)
    case event(title: String, text: String, timestamp: Date?, hostname: String?, aggregationKey: String?, priority: EventPriority?, sourceTypeName: String?, alertType: EventAlertType?)
    
    var toWire: String {
        switch self {
        case let .count(name, value):           return "\(name):\(value)|c"
        case let .gauge(name, value):           return "\(name):\(value)|g"
        case let .histogram(name, value):       return "\(name):\(value)|h"
        case let .distribution(name, value):    return "\(name):\(value)|d"
        case let .set(name, value):             return "\(name):\(value)|s"
        case let .timing(name, value):          return "\(name):\(value.toMs)|ms"
        
        case let .serviceCheck(name, status, timestamp, hostname, message):
            return "_sc|\(name)|\(status.rawValue)"
            + timestamp.statsdFormat("|d:") { $0 }
            + hostname.statsdFormat("|d:") { $0 }
            + message.statsdFormat("|d:") { $0 }
            
        case let .event(title, text, timestamp, hostname, aggregationKey, priority, sourceTypeName, alertType):
            return "_e{\(title.count),\(text.count)}:\(title)|\(text)"
            + timestamp.statsdFormat("|d:") { $0.timeIntervalSince1970.toMs }
            + hostname.statsdFormat("|h:") { $0 }
            + aggregationKey.statsdFormat("|k:") { $0 }
            + priority.statsdFormat("|p:") { $0.rawValue }
            + sourceTypeName.statsdFormat("|s:") { $0 }
            + alertType.statsdFormat("|t:") { $0 }
        }
    }
}

public protocol DogstatsdClient {
    var sender: StatsdSender { get }
}

extension DogstatsdClient {
    
    public func count(_ name: String, value: Int64, tags: [String: String] = [:], rate: Float = 1) {
        sender.send(metric: .count(name: name, value: value), tags: tags, rate: rate)
    }
    
    public func increment(_ name: String, tags: [String: String] = [:], rate: Float = 1) {
        count(name, value: 1, tags: tags, rate: rate)
    }
    
    public func decrement(_ name: String, tags: [String: String] = [:], rate: Float = 1) {
        count(name, value: -1, tags: tags, rate: rate)
    }
    
    public func gauge(_ name: String, value: Float64, tags: [String: String] = [:], rate: Float = 1) {
        sender.send(metric: .gauge(name: name, value: value), tags: tags, rate: rate)
    }
    
    public func histogram(_ name: String, value: Float64, tags: [String: String] = [:], rate: Float = 1) {
        sender.send(metric: .histogram(name: name, value: value), tags: tags, rate: rate)
    }
    
    public func distribution(_ name: String, value: Float64, tags: [String: String] = [:], rate: Float = 1) {
        sender.send(metric: .histogram(name: name, value: value), tags: tags, rate: rate)
    }
    
    public func set(_ name: String, value: String, tags: [String: String] = [:], rate: Float = 1) {
        sender.send(metric: .set(name: name, value: value), tags: tags, rate: rate)
    }
    
    public func timing(_ name: String, value: TimeInterval, tags: [String: String] = [:], rate: Float = 1) {
        sender.send(metric: .timing(name: name, value: value), tags: tags, rate: rate)
    }
    
    public func serviceCheck(name: String,
                      status: ServiceCheckStatus,
                      timestamp: Date? = nil,
                      hostname: String? = nil,
                      message: String? = nil,
                      tags: [String: String] = [:]) {
        sender.send(metric: .serviceCheck(name: name,
                                          status: status,
                                          timestamp: timestamp,
                                          hostname: hostname,
                                          message: message),
                    tags: tags,
                    rate: 1)
    }
    
    public func event(title: String,
               text: String,
               timestamp: Date? = nil,
               hostname: String? = nil,
               aggregationKey: String? = nil,
               priority: EventPriority? = nil,
               sourceTypeName: String? = nil,
               alertType: EventAlertType? = nil,
               tags: [String: String] = [:]) {
        
        sender.send(metric: .event(title: title,
                                   text: text,
                                   timestamp: timestamp,
                                   hostname: hostname,
                                   aggregationKey: aggregationKey,
                                   priority: priority,
                                   sourceTypeName: sourceTypeName,
                                   alertType: alertType),
                    tags: tags,
                    rate: 1)
        
        
    }
}

fileprivate extension Optional {
    func statsdFormat<U>(_ prefix: String, format: ((Wrapped) -> U)) -> String {
        switch self {
        case .some(let val):
            let formatted = "\(format(val))"
            return formatted.count > 0 ? "\(prefix)\(formatted)" : ""
        case .none:
            return ""
        }
    }
}

fileprivate extension TimeInterval {
    var toMs: Int {
        Int(self * 1_000)
    }
}
