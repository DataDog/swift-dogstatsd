import DogstatsdCore
import Foundation
import NIOPosix

@main
enum DogstatsdNIOExample {
    static func main() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            try? eventLoopGroup.syncShutdownGracefully()
        }

        let host = ProcessInfo.processInfo.environment["DOGSTATSD_HOST"] ?? "127.0.0.1"
        let port = Int(ProcessInfo.processInfo.environment["DOGSTATSD_PORT"] ?? "8125") ?? 8125

        let client = try NIODogstatsdClient(
            on: eventLoopGroup,
            clientConfig: .udp(address: host, port: port)
        )

        client.increment("example.nio.started", tags: ["source:nio-example"])
        client.gauge("example.nio.port", value: Float64(port), tags: ["source:nio-example"])
        try client.shutdown()

        print("Sent DogStatsD example metrics to \(host):\(port)")
    }
}
