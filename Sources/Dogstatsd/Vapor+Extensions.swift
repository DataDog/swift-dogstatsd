/// Unless explicitly stated otherwise all files in this repository are licensed under the MIT License.
/// This product includes software developed at Datadog (https://www.datadoghq.com/)  Copyright 2022 Datadog, Inc.

import Foundation
import Vapor

public class AsyncDogstatsdClient: DogstatsdClient {
    
    let app: Application
    public var sender: StatsdSender {
        guard let configuredSender = configuredSender else {
            fatalError("Dogstatsd not configured")
        }
        return configuredSender
    }
    
    private var configuredSender: StatsdSender?
    
    public var config: ClientConfig? {
        didSet {
            guard let config = config else {
                return
            }
            do {
                try configuredSender = VaporSender(client: SocketWriteClient(on: app.eventLoopGroup,
                                                                             clientConfig: config),
                                                   eventLoop: app.eventLoopGroup.next())
            } catch {
                print("Warning: Failed to init dogstatsd client: \(error)")
            }
        }
    }
    
    init(app: Application) {
        self.app = app
    }
}

extension Request {
    public var dogstatsd: AsyncDogstatsdClient {
        return application.dogstatsd
    }
}

extension Application {
    
    private struct Key: StorageKey {
        typealias Value = AsyncDogstatsdClient
    }
    
    public var dogstatsd: AsyncDogstatsdClient {
        if storage[Key.self] == nil {
            storage[Key.self] = AsyncDogstatsdClient(app: self)
        }
        
        return storage[Key.self]!
    }
}
