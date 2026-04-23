@testable import DogstatsdCore
import Foundation
import NIO
import XCTest

final class RecordingStatsdSender: StatsdSender {
    var globalTags: [String] = []
    private(set) var sentMetrics: [String] = []

    func sendRaw(metric: String) {
        sentMetrics.append(metric)
    }
}

final class TestDogstatsdClient: DogstatsdClient {
    let recordingSender = RecordingStatsdSender()

    var sender: StatsdSender {
        recordingSender
    }
}

final class UDPTestReceiver {
    let port: Int

    private let channel: Channel
    private let receivedMessages = LockedMessages()

    init(group: EventLoopGroup) throws {
        let handler = UDPCollectorHandler(receivedMessages: receivedMessages)
        self.channel = try DatagramBootstrap(group: group)
            .channelInitializer { channel in
                channel.pipeline.addHandler(handler)
            }
            .bind(host: "127.0.0.1", port: 0)
            .wait()

        self.port = channel.localAddress?.port ?? 0
    }

    func waitForMessage(file: StaticString = #filePath, line: UInt = #line) throws -> String {
        let deadline = Date().addingTimeInterval(1)
        while Date() < deadline {
            if let message = receivedMessages.popFirst() {
                return message
            }
            usleep(10_000)
        }

        XCTFail("Timed out waiting for UDP payload", file: file, line: line)
        throw TimeoutError()
    }

    func shutdown() throws {
        try channel.close().wait()
    }
}

private final class UDPCollectorHandler: ChannelInboundHandler, @unchecked Sendable {
    typealias InboundIn = AddressedEnvelope<ByteBuffer>

    private let receivedMessages: LockedMessages

    init(receivedMessages: LockedMessages) {
        self.receivedMessages = receivedMessages
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var envelope = unwrapInboundIn(data)
        if let message = envelope.data.readString(length: envelope.data.readableBytes) {
            receivedMessages.append(message)
        }
    }
}

private final class LockedMessages {
    private let lock = NSLock()
    private var messages: [String] = []

    func append(_ message: String) {
        lock.lock()
        messages.append(message)
        lock.unlock()
    }

    func popFirst() -> String? {
        lock.lock()
        defer { lock.unlock() }

        guard !messages.isEmpty else {
            return nil
        }
        return messages.removeFirst()
    }
}

private struct TimeoutError: Error {}
