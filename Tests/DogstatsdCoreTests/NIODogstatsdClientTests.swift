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
}
