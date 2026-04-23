@testable import Dogstatsd
import Foundation
import XCTest

final class MetricEncodingTests: XCTestCase {
    func testPrimitiveMetricWireFormats() {
        XCTAssertEqual(DogstatsdMetric.count(name: "requests", value: 3).toWire, "requests:3|c")
        XCTAssertEqual(DogstatsdMetric.gauge(name: "cpu", value: 0.42).toWire, "cpu:0.42|g")
        XCTAssertEqual(DogstatsdMetric.histogram(name: "latency", value: 12).toWire, "latency:12.0|h")
        XCTAssertEqual(DogstatsdMetric.distribution(name: "payload", value: 98.7).toWire, "payload:98.7|d")
        XCTAssertEqual(DogstatsdMetric.set(name: "host", value: "web-1").toWire, "host:web-1|s")
        XCTAssertEqual(DogstatsdMetric.timing(name: "query", value: 0.043).toWire, "query:43|ms")
    }

    func testServiceCheckEncodingIncludesOptionalFields() {
        let encoded = DogstatsdMetric.serviceCheck(
            name: "database.health",
            status: .critical,
            timestamp: Date(timeIntervalSince1970: 1_535_776_860),
            hostname: "db-1",
            message: "Connection timed out"
        ).toWire

        XCTAssertEqual(
            encoded,
            "_sc|database.health|2|d:1535776860|h:db-1|m:Connection timed out"
        )
    }

    func testServiceCheckEncodingOmitsNilAndEmptyOptionalFields() {
        let encoded = DogstatsdMetric.serviceCheck(
            name: "cache.health",
            status: .warn,
            timestamp: nil,
            hostname: "",
            message: nil
        ).toWire

        XCTAssertEqual(encoded, "_sc|cache.health|1")
    }

    func testEventEncodingUsesByteCountsAndMetadata() {
        let title = "deploy 🚀"
        let text = "all good\nline two"
        let encoded = DogstatsdMetric.event(
            title: title,
            text: text,
            timestamp: Date(timeIntervalSince1970: 1_700_000_000),
            hostname: "api-1",
            aggregationKey: "deploy",
            priority: .low,
            sourceTypeName: "swift",
            alertType: .error
        ).toWire

        XCTAssertEqual(
            encoded,
            "_e{\(title.bytesCount),\(text.bytesCount)}:\(title)|\(text)|d:1700000000000|h:api-1|k:deploy|p:low|s:swift|t:error"
        )
    }
}
