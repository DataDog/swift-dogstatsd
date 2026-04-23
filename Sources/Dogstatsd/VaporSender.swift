/// Unless explicitly stated otherwise all files in this repository are licensed under the MIT License.
/// This product includes software developed at Datadog (https://www.datadoghq.com/)  Copyright 2022 Datadog, Inc.

import Foundation
import Vapor

/// A vapor specific non-blocking dogstatsd sender.
final class VaporSender: StatsdSender, @unchecked Sendable {
    var globalTags: [String]
    
    private let client: SocketWriteClient
    
    // Pin the event loop. this will be useful for aggregation in the future.
    private let eventLoop: EventLoop
    
    init(client: SocketWriteClient, eventLoop: EventLoop, globalTags: [String]) {
        self.client = client
        self.eventLoop = eventLoop
        self.globalTags = globalTags
    }
    
    func sendRaw(metric: String) {
        let client = self.client
        eventLoop.execute {
            client.send(payload: metric)
        }
    }
}
