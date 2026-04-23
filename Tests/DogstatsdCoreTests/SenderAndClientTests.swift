@testable import DogstatsdCore
import XCTest

final class SenderAndClientTests: XCTestCase {
    func testSenderAppendsGlobalAndPerCallTags() {
        let sender = RecordingStatsdSender()
        sender.globalTags = ["env:prod", "service:checkout"]

        sender.send(
            metric: .count(name: "checkout.request", value: 1),
            tags: ["region:use1"],
            rate: 1
        )

        XCTAssertEqual(
            sender.sentMetrics,
            ["checkout.request:1|c|#env:prod,service:checkout,region:use1"]
        )
    }

    func testSenderDoesNotEmitWhenSamplingRateIsZero() {
        let sender = RecordingStatsdSender()

        sender.send(
            metric: .count(name: "checkout.request", value: 1),
            tags: [],
            rate: 0
        )

        XCTAssertEqual(sender.sentMetrics, [])
    }

    func testSampledCountIncludesSampleRateInPayload() {
        let sender = RecordingStatsdSender()

        for _ in 0..<1_000 where sender.sentMetrics.isEmpty {
            sender.send(
                metric: .count(name: "checkout.request", value: 1),
                tags: [],
                rate: 0.5
            )
        }

        XCTAssertEqual(sender.sentMetrics.last, "checkout.request:1|c|@0.5")
    }

    func testServiceCheckPlacesTagsBeforeMessage() {
        let client = TestDogstatsdClient()

        client.serviceCheck(
            name: "database.health",
            status: .critical,
            timestamp: Date(timeIntervalSince1970: 1_535_776_860),
            hostname: "db-1",
            message: "Connection timed out",
            tags: ["env:prod", "region:use1"]
        )

        XCTAssertEqual(
            client.recordingSender.sentMetrics.last,
            "_sc|database.health|2|d:1535776860|h:db-1|#env:prod,region:use1|m:Connection timed out"
        )
    }

    func testConvenienceMethodsEncodeExpectedPayloads() {
        let client = TestDogstatsdClient()

        client.increment("requests")
        XCTAssertEqual(client.recordingSender.sentMetrics.last, "requests:1|c")

        client.decrement("requests")
        XCTAssertEqual(client.recordingSender.sentMetrics.last, "requests:-1|c")

        client.gauge("temperature", value: 21.5, tags: ["room:server"])
        XCTAssertEqual(client.recordingSender.sentMetrics.last, "temperature:21.5|g|#room:server")

        client.count("jobs", value: 2, tags: ["queue": "critical"])
        XCTAssertEqual(client.recordingSender.sentMetrics.last, "jobs:2|c|#queue:critical")

        client.event(
            title: "deploy",
            text: "complete",
            hostname: "api-1",
            alertType: .success,
            tags: ["env:prod"]
        )
        XCTAssertEqual(
            client.recordingSender.sentMetrics.last,
            "_e{6,8}:deploy|complete|h:api-1|t:success|#env:prod"
        )
    }
}
