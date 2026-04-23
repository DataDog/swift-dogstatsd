@testable import Dogstatsd
import NIO
import XCTest

final class SocketWriteClientTests: XCTestCase {
    func testClientRecreatesClosedChannelBeforeSendingAgain() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let receiver = try UDPTestReceiver(group: eventLoopGroup)
        defer {
            XCTAssertNoThrow(try receiver.shutdown())
        }

        let client = try SocketWriteClient(
            on: eventLoopGroup,
            clientConfig: .udp(address: "127.0.0.1", port: receiver.port)
        )

        client.send(payload: "first")
        XCTAssertEqual(try receiver.waitForMessage(), "first")

        let channel = try XCTUnwrap(waitForChannel(in: client))
        XCTAssertNoThrow(try channel.close().wait())

        client.send(payload: "second")
        XCTAssertEqual(try receiver.waitForMessage(), "second")
    }

    private func waitForChannel(in client: SocketWriteClient) -> Channel? {
        let deadline = Date().addingTimeInterval(1)
        while Date() < deadline {
            if let channel = reflectedChannel(in: client) {
                return channel
            }
            usleep(10_000)
        }
        return nil
    }

    private func reflectedChannel(in client: SocketWriteClient) -> Channel? {
        Mirror(reflecting: client)
            .children
            .first(where: { $0.label == "channel" })?
            .value as? Channel
    }
}
