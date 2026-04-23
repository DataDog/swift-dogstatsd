/// Unless explicitly stated otherwise all files in this repository are licensed under the MIT License.
/// This product includes software developed at Datadog (https://www.datadoghq.com/)  Copyright 2022 Datadog, Inc.

import Foundation
import NIO

public final class NIODogstatsdClient: DogstatsdClient, @unchecked Sendable {
    public let sender: StatsdSender

    public init(
        on eventLoopGroup: EventLoopGroup,
        clientConfig: ClientConfig,
        eventLoop: EventLoop? = nil,
        globalTags: [String] = NIODogstatsdClient.environmentGlobalTags
    ) throws {
        self.sender = EventLoopStatsdSender(
            client: try SocketWriteClient(on: eventLoopGroup, clientConfig: clientConfig),
            eventLoop: eventLoop ?? eventLoopGroup.next(),
            globalTags: globalTags
        )
    }

    public static var environmentGlobalTags: [String] {
        environmentGlobalTags(from: ProcessInfo.processInfo.environment)
    }

    public static func environmentGlobalTags(from environment: [String: String]) -> [String] {
        [
            "DD_ENV": "env",
            "DD_SERVICE": "service",
            "DD_VERSION": "version",
            "DD_ENTITY_ID": "dd.internal.entity_id"
        ].compactMap { envVar, tag in
            guard let value = environment[envVar] else {
                return nil
            }
            return "\(tag):\(value)"
        }
    }
}

final class EventLoopStatsdSender: StatsdSender, @unchecked Sendable {
    var globalTags: [String]

    private let client: SocketWriteClient
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
