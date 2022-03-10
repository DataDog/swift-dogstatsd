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
            _ = self.client.send(payload: metric)
        }
    }
}
