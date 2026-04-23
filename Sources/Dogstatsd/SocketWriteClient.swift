/// Unless explicitly stated otherwise all files in this repository are licensed under the MIT License.
/// This product includes software developed at Datadog (https://www.datadoghq.com/)  Copyright 2022 Datadog, Inc.

import Foundation
import NIO

public enum ClientConfig {
    case udp(address: String, port: Int)
    case uds(path: String)
    case disabled
}

// A write-only Socket client
public final class SocketWriteClient: @unchecked Sendable {
    public let eventLoopGroup: EventLoopGroup
    private let remoteAddress: SocketAddress?
    private let config: ClientConfig
    private let stateLock = NSLock()
    private var channel: Channel?
    private var bootstrapFuture: EventLoopFuture<Channel>?
    private var pendingPayloads: [String] = []
    
    public init(on eventLoopGroup: EventLoopGroup, clientConfig: ClientConfig) throws {
        self.eventLoopGroup = eventLoopGroup
        self.config = clientConfig
    
        switch clientConfig {
        case .udp(let host, let sendPort):
            remoteAddress = try SocketAddress.makeAddressResolvingHost(host, port: sendPort)
        case .uds(let sendPath):
            remoteAddress = try SocketAddress(unixDomainSocketPath: sendPath)
        case .disabled:
            remoteAddress = nil
        }
    }
    
    package func send(payload: String) {
        guard let remoteAddress = remoteAddress else {
            return
        }

        let action = stateLock.withLock { () -> SendAction in
            pendingPayloads.append(payload)

            if let channel, channel.isActive {
                return .flush(channel)
            }

            if bootstrapFuture != nil {
                return .none
            }

            bootstrapFuture = makeBootstrap(remoteAddress: remoteAddress)
            return .waitForBootstrap
        }

        switch action {
        case .none:
            return
        case .flush(let channel):
            _ = flushPending(on: channel, remoteAddress: remoteAddress)
        case .waitForBootstrap:
            return
        }
    }

    private func makeBootstrap(remoteAddress: SocketAddress) -> EventLoopFuture<Channel> {
        let bootstrap = DatagramBootstrap(group: eventLoopGroup)
            .channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .channelInitializer { [weak self] channel in
                channel.pipeline.addHandler(SocketHandler(client: self))
            }

        let bindFuture: EventLoopFuture<Channel>
        switch config {
        case .udp:
            // In order to send UDP packets, NIO requires us to also bind to a recieve socket - this is a workaround
            bindFuture = bootstrap.bind(host: "0.0.0.0", port: 0)
        case .uds:
            // (like above) In order to send UDS packets, NIO requires us to also bind to a recieve socket - this is a workaround
            bindFuture = bootstrap.bind(
                unixDomainSocketPath: "/tmp/swiftdogstatsdnoopsock",
                cleanupExistingSocketFile: true
            )
        case .disabled:
            bindFuture = eventLoopGroup.next().makeFailedFuture(SocketClientError.disabledClient)
        }

        bindFuture.whenSuccess { [weak self] channel in
            guard let self else { return }

            self.stateLock.withLock {
                self.channel = channel
                self.bootstrapFuture = nil
            }

            _ = self.flushPending(on: channel, remoteAddress: remoteAddress)

            channel.closeFuture.whenComplete { _ in
                self.clearChannel(channel)
            }
        }

        bindFuture.whenFailure { [weak self] _ in
            self?.stateLock.withLock {
                self?.bootstrapFuture = nil
                self?.pendingPayloads.removeAll()
            }
        }

        return bindFuture
    }

    func shutdown() -> EventLoopFuture<Void> {
        let action = stateLock.withLock { () -> ShutdownAction in
            if let bootstrapFuture {
                return .waitForBootstrap(bootstrapFuture)
            }

            if let channel {
                self.channel = nil
                return .close(channel)
            }

            return .none(eventLoopGroup.next().makeSucceededFuture(()))
        }

        switch action {
        case .waitForBootstrap(let bootstrapFuture):
            return bootstrapFuture.flatMap { [weak self] channel in
                guard let self else {
                    return channel.eventLoop.makeSucceededFuture(())
                }
                return self.close(channel: channel)
            }
        case .close(let channel):
            return close(channel: channel)
        case .none(let future):
            return future
        }
    }

    private func flushPending(on channel: Channel, remoteAddress: SocketAddress) -> EventLoopFuture<Void> {
        let payloads = stateLock.withLock { () -> [String] in
            guard channel.isActive else {
                return []
            }

            let payloads = pendingPayloads
            pendingPayloads.removeAll()
            return payloads
        }

        guard !payloads.isEmpty else {
            return channel.eventLoop.makeSucceededFuture(())
        }

        var flushFutures: [EventLoopFuture<Void>] = []
        for payload in payloads {
            let buffer = channel.allocator.buffer(string: payload)
            let envelope = AddressedEnvelope<ByteBuffer>(remoteAddress: remoteAddress, data: buffer)
            let writeFuture = channel.writeAndFlush(envelope)
            writeFuture.whenFailure { [weak self] _ in
                self?.handleFailedChannel(channel)
            }
            flushFutures.append(writeFuture)
        }

        return EventLoopFuture.andAllSucceed(flushFutures, on: channel.eventLoop)
    }

    private func close(channel: Channel) -> EventLoopFuture<Void> {
        let flushFuture: EventLoopFuture<Void>
        if let remoteAddress {
            flushFuture = flushPending(on: channel, remoteAddress: remoteAddress)
        } else {
            flushFuture = channel.eventLoop.makeSucceededFuture(())
        }

        return flushFuture.flatMap {
            channel.close()
        }
    }

    fileprivate func handleFailedChannel(_ channel: Channel) {
        clearChannel(channel)
        channel.close(promise: nil)
    }

    private func clearChannel(_ channel: Channel) {
        stateLock.withLock {
            guard self.channel === channel else {
                return
            }
            self.channel = nil
        }
    }
}

private final class SocketHandler: ChannelInboundHandler, @unchecked Sendable {
    public typealias InboundIn = AddressedEnvelope<ByteBuffer>
    public typealias OutboundOut = AddressedEnvelope<ByteBuffer>

    private weak var client: SocketWriteClient?

    init(client: SocketWriteClient?) {
        self.client = client
    }
    
    public func channelActive(context: ChannelHandlerContext) {}
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {}
    
    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        client?.handleFailedChannel(context.channel)
        context.close(promise: nil)
    }
}

private enum SendAction {
    case none
    case flush(Channel)
    case waitForBootstrap
}

private enum ShutdownAction {
    case waitForBootstrap(EventLoopFuture<Channel>)
    case close(Channel)
    case none(EventLoopFuture<Void>)
}

private enum SocketClientError: Error {
    case disabledClient
}

private extension NSLock {
    func withLock<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}
