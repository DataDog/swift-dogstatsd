/// Unless explicitly stated otherwise all files in this repository are licensed under the MIT License.
/// This product includes software developed at Datadog (https://www.datadoghq.com/)  Copyright 2022 Datadog, Inc.

@_exported import DogstatsdCore
import Foundation
import Vapor

public final class AsyncDogstatsdClient: DogstatsdClient, @unchecked Sendable {
    let app: Application
    private let stateLock = NSLock()
    private let fallbackSender: StatsdSender

    public var sender: StatsdSender {
        stateLock.withLock {
            configuredClient?.sender ?? fallbackSender
        }
    }

    var globalTags: [String] {
        NIODogstatsdClient.environmentGlobalTags
    }

    private var storedConfig: ClientConfig?
    private var configuredClient: NIODogstatsdClient?

    public var config: ClientConfig? {
        get {
            stateLock.withLock {
                storedConfig
            }
        }
        set {
            stateLock.withLock {
                storedConfig = newValue
            }

            guard let config = newValue else {
                return
            }

            do {
                let client = try NIODogstatsdClient(
                    on: app.eventLoopGroup,
                    clientConfig: config,
                    eventLoop: app.eventLoopGroup.next(),
                    globalTags: globalTags
                )
                stateLock.withLock {
                    configuredClient = client
                }
            } catch {
                app.logger.warning("Failed to initialize Dogstatsd client: \(String(reflecting: error))")
            }
        }
    }

    init(app: Application) {
        self.app = app
        self.fallbackSender = DisabledStatsdSender(globalTags: NIODogstatsdClient.environmentGlobalTags)
    }
}

extension Request {
    public var dogstatsd: AsyncDogstatsdClient {
        application.dogstatsd
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

private final class DisabledStatsdSender: StatsdSender, @unchecked Sendable {
    let globalTags: [String]

    init(globalTags: [String]) {
        self.globalTags = globalTags
    }

    func sendRaw(metric: String) {}
}

private extension NSLock {
    func withLock<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}
