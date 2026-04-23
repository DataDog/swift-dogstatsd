@testable import Dogstatsd
import NIO
import XCTest

final class NIODogstatsdClientTests: XCTestCase {
    func testEnvironmentGlobalTagsMapsKnownVariables() {
        XCTAssertEqual(
            Set(
                NIODogstatsdClient.environmentGlobalTags(
                    from: [
                        "DD_ENV": "prod",
                        "DD_SERVICE": "checkout",
                        "DD_VERSION": "1.2.3",
                        "DD_ENTITY_ID": "entity-123",
                    ]
                )
            ),
            Set([
                "env:prod",
                "service:checkout",
                "version:1.2.3",
                "dd.internal.entity_id:entity-123",
            ])
        )
    }

    func testClientUsesProvidedGlobalTags() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let client = try NIODogstatsdClient(
            on: eventLoopGroup,
            clientConfig: .disabled,
            globalTags: ["env:test"]
        )

        XCTAssertEqual(client.sender.globalTags, ["env:test"])
    }

    func testShutdownFlushesPendingMetricsForShortLivedClient() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let receiver = try UDPTestReceiver(group: eventLoopGroup)
        defer {
            XCTAssertNoThrow(try receiver.shutdown())
        }

        let client = try NIODogstatsdClient(
            on: eventLoopGroup,
            clientConfig: .udp(address: "127.0.0.1", port: receiver.port)
        )

        client.increment("example.nio.started", tags: ["source:nio-example"])
        client.gauge("example.nio.port", value: Float64(receiver.port), tags: ["source:nio-example"])

        XCTAssertNoThrow(try client.shutdown())
        XCTAssertEqual(try receiver.waitForMessage(), "example.nio.started:1|c|#source:nio-example")
        XCTAssertEqual(try receiver.waitForMessage(), "example.nio.port:\(Float64(receiver.port))|g|#source:nio-example")
    }
}
