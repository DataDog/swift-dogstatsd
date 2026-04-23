@testable import Dogstatsd
import NIO
import Vapor
import XCTVapor

final class BackwardCompatibilityTests: XCTestCase {
    func testCompatibilityModuleExportsCoreClient() throws {
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
        XCTAssertNoThrow(try client.shutdown())
    }

    func testCompatibilityModuleExportsVaporExtensions() async throws {
        let app = try await Application.make(.testing)
        do {
            app.dogstatsd.config = .disabled
            XCTAssertEqual(app.dogstatsd.sender.globalTags, NIODogstatsdClient.environmentGlobalTags)
            try await app.asyncShutdown()
        } catch {
            try? await app.asyncShutdown()
            throw error
        }
    }
}
