import DogstatsdVapor
import Foundation
import Vapor

@main
enum DogstatsdVaporExample {
    static func main() async throws {
        let app = try await Application.make(.development)

        app.dogstatsd.config = .udp(
            address: ProcessInfo.processInfo.environment["DOGSTATSD_HOST"] ?? "127.0.0.1",
            port: Int(ProcessInfo.processInfo.environment["DOGSTATSD_PORT"] ?? "8125") ?? 8125
        )

        app.get { req in
            req.dogstatsd.increment("example.vapor.request", tags: ["source:vapor-example"])
            return "Dogstatsd Vapor example is running.\n"
        }

        do {
            try await app.execute()
            try await app.asyncShutdown()
        } catch {
            try? await app.asyncShutdown()
            throw error
        }
    }
}
