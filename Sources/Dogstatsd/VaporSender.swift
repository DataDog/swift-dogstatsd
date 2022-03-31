/// Unless explicitly stated otherwise all files in this repository are licensed under the MIT License.
/// This product includes software developed at Datadog (https://www.datadoghq.com/)  Copyright 2022 Datadog, Inc.

import Foundation
import Vapor

/// A vapor specific non-blocking dogstatsd sender.
class VaporSender: StatsdSender {
    private let client: SocketWriteClient
    
    // Pin the event loop. this will be useful for aggregation in the future.
    private let eventLoop: EventLoop
    
    init(client: SocketWriteClient, eventLoop: EventLoop) {
        self.client = client
        self.eventLoop = eventLoop
    }
    
    func sendRaw(metric: String) {
        eventLoop.execute {
            self.client.send(payload: metric)
        }
    }
}
