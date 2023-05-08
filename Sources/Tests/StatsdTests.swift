/// Unless explicitly stated otherwise all files in this repository are licensed under the MIT License.
/// This product includes software developed at Datadog (https://www.datadoghq.com/)  Copyright 2022 Datadog, Inc.

@testable import Dogstatsd
import XCTest

final class AppTests: XCTestCase {
    func testDogStatsd() {
        let client = TestDogStatsdClient()
        
        // timing
        client.timing("some.timing_metric", value: 43 / 1000, tags: ["horse:cart"])
        XCTAssertEqual(client.encodedMetric, "some.timing_metric:43|ms|#horse:cart")
        
        client.timing("some.timing_metric", value: 43 / 1000, tags: ["horse": "cart"])
        XCTAssertEqual(client.encodedMetric, "some.timing_metric:43|ms|#horse:cart")
       
        // gauge
        client.gauge("some.gauge_metric", value: 5, tags: ["baseball:cap"])
        XCTAssertEqual(client.encodedMetric, "some.gauge_metric:5.0|g|#baseball:cap")
        
        
        client.gauge("some.gauge_metric", value: 0, tags: ["baseball:cap"])
        XCTAssertEqual(client.encodedMetric, "some.gauge_metric:0.0|g|#baseball:cap")
        
        client.gauge("some.gauge_metric", value: 0, tags: ["baseball": "cap"])
        XCTAssertEqual(client.encodedMetric, "some.gauge_metric:0.0|g|#baseball:cap")
        
        client.gauge("some.gauge_metric", value: 0)
        XCTAssertEqual(client.encodedMetric, "some.gauge_metric:0.0|g")
        
        // histogram
        client.histogram("some.histogram_metric", value: 109, tags: ["happy:days"])
        XCTAssertEqual(client.encodedMetric, "some.histogram_metric:109.0|h|#happy:days")
        
        client.histogram("some.histogram_metric", value: 109, tags: ["happy": "days"])
        XCTAssertEqual(client.encodedMetric, "some.histogram_metric:109.0|h|#happy:days")
        
        client.histogram("some.histogram_metric", value: 109)
        XCTAssertEqual(client.encodedMetric, "some.histogram_metric:109.0|h")
        
        // distribution
        client.distribution("some.distribution_metric", value: 7, tags: ["floppy:hat"])
        XCTAssertEqual(client.encodedMetric, "some.distribution_metric:7.0|d|#floppy:hat")
        
        client.distribution("some.distribution_metric", value: 7, tags: ["floppy": "hat"])
        XCTAssertEqual(client.encodedMetric, "some.distribution_metric:7.0|d|#floppy:hat")
        
        client.distribution("some.distribution_metric", value: 7)
        XCTAssertEqual(client.encodedMetric, "some.distribution_metric:7.0|d")
        
        // service checks
        client.serviceCheck(name: "neat-service",
                            status: .critical,
                            timestamp: Date(timeIntervalSince1970: 1535776860),
                            hostname: "some-host.com",
                            message: "Important message",
                            tags: ["red:balloon"])
        XCTAssertEqual(client.encodedMetric, "_sc|neat-service|2|d:1535776860|h:some-host.com|m:Important message|#red:balloon")
        
        client.serviceCheck(name: "neat-service",
                            status: .ok,
                            timestamp: Date(timeIntervalSince1970: 1535776860),
                            hostname: "some-host.com",
                            message: "Important message")
        XCTAssertEqual(client.encodedMetric, "_sc|neat-service|0|d:1535776860|h:some-host.com|m:Important message")
        
        client.serviceCheck(name: "neat-service",
                            status: .ok,
                            timestamp: Date(timeIntervalSince1970: 1535776860),
                            message: "Important message",
                            tags: ["red:balloon"])
        XCTAssertEqual(client.encodedMetric, "_sc|neat-service|0|d:1535776860|m:Important message|#red:balloon")
        
        client.serviceCheck(name: "neat-service",
                            status: .warn,
                            timestamp: Date(timeIntervalSince1970: 1535776860),
                            hostname: "some-host.com",
                            tags: ["red:balloon"])
        XCTAssertEqual(client.encodedMetric, "_sc|neat-service|1|d:1535776860|h:some-host.com|#red:balloon")
        
        client.serviceCheck(name: "neat-service",
                            status: .unknown,
                            hostname: "some-host.com",
                            message: "Important message",
                            tags: ["red:balloon"])
        XCTAssertEqual(client.encodedMetric, "_sc|neat-service|3|h:some-host.com|m:Important message|#red:balloon")
        
        client.serviceCheck(name: "neat-service",
                            status: .unknown,
                            hostname: "some-host.com",
                            message: "Important message",
                            tags: ["red": "balloon"])
        XCTAssertEqual(client.encodedMetric, "_sc|neat-service|3|h:some-host.com|m:Important message|#red:balloon")
        
        // count
        client.increment("some.count")
        XCTAssertEqual(client.encodedMetric, "some.count:1|c")
        
        client.decrement("some.count")
        XCTAssertEqual(client.encodedMetric, "some.count:-1|c")
        
        client.count("some.count", value: 123)
        XCTAssertEqual(client.encodedMetric, "some.count:123|c")
        
        client.count("some.count", value: 123, tags: ["some:tag"])
        XCTAssertEqual(client.encodedMetric, "some.count:123|c|#some:tag")
        
        client.count("some.count", value: 123, tags: ["some": "tag"])
        XCTAssertEqual(client.encodedMetric, "some.count:123|c|#some:tag")
        
        // set
        client.set("set", value: "foo")
        XCTAssertEqual(client.encodedMetric, "set:foo|s")
        
        client.set("set", value: "123", tags: ["some:tag"])
        XCTAssertEqual(client.encodedMetric, "set:123|s|#some:tag")
        
        client.set("set", value: "123", tags: ["some": "tag"])
        XCTAssertEqual(client.encodedMetric, "set:123|s|#some:tag")
    }
    
    func testGloalTags() {
        let client = TestDogStatsdClient()
        client.testSender.globalTags = ["foo:bar"]
        client.increment("some.count")
        XCTAssertEqual(client.encodedMetric, "some.count:1|c|#foo:bar")
        
        client.testSender.globalTags = ["foo:bar,abc:123"]
        client.increment("some.count")
        XCTAssertEqual(client.encodedMetric, "some.count:1|c|#foo:bar,abc:123")
        
        client.testSender.globalTags = ["foo:bar,abc:123"]
        client.increment("some.count", tags: ["some:tag"])
        XCTAssertEqual(client.encodedMetric, "some.count:1|c|#foo:bar,abc:123,some:tag")
    }
}

class TestStatsdSender: StatsdSender {
    var globalTags: [String] = []
    
    var encodedMetric: String = ""
    
    func sendRaw(metric: String) {
        encodedMetric = metric
    }
}

class TestDogStatsdClient: DogstatsdClient {
    var encodedMetric: String {
        return testSender.encodedMetric
    }
    
    var testSender = TestStatsdSender()
    var sender: StatsdSender {
        testSender
    }
}
