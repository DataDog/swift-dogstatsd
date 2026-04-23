@testable import Dogstatsd
import Foundation
import Vapor
import XCTVapor

final class VaporIntegrationTests: XCTestCase {
    func testApplicationStorageMemoizesDogstatsdClient() async throws {
        try await withApplication { app in
            XCTAssertTrue(app.dogstatsd === app.dogstatsd)
        }
    }

    func testRequestUsesApplicationDogstatsdClient() async throws {
        try await withApplication { app in
            app.get("dogstatsd") { req in
                req.dogstatsd === app.dogstatsd ? "true" : "false"
            }

            try await app.test(.GET, "dogstatsd") { response async throws in
                XCTAssertEqual(response.status, .ok)
                XCTAssertEqual(response.body.string, "true")
            }
        }
    }

    func testConfiguredSenderCarriesEnvironmentDerivedTags() async throws {
        try await withEnvironment([
            "DD_ENV": "prod",
            "DD_SERVICE": "checkout",
            "DD_VERSION": "1.2.3",
            "DD_ENTITY_ID": "entity-123",
        ]) {
            try await withApplication { app in
                app.dogstatsd.config = .disabled

                XCTAssertEqual(
                    Set(app.dogstatsd.sender.globalTags),
                    Set([
                        "env:prod",
                        "service:checkout",
                        "version:1.2.3",
                        "dd.internal.entity_id:entity-123",
                    ])
                )
            }
        }
    }

    private func withEnvironment(
        _ values: [String: String?],
        perform body: () async throws -> Void
    ) async throws {
        var originalValues = values.mapValues { _ in Optional<String>.none }
        for key in values.keys {
            originalValues[key] = ProcessInfo.processInfo.environment[key]
        }

        for (key, value) in values {
            if let value {
                setenv(key, value, 1)
            } else {
                unsetenv(key)
            }
        }

        defer {
            for (key, value) in originalValues {
                if let value {
                    setenv(key, value, 1)
                } else {
                    unsetenv(key)
                }
            }
        }

        try await body()
    }

    private func withApplication(
        _ body: (Application) async throws -> Void
    ) async throws {
        let app = try await Application.make(.testing)
        do {
            try await body(app)
            try await app.asyncShutdown()
        } catch {
            try? await app.asyncShutdown()
            throw error
        }
    }
}
