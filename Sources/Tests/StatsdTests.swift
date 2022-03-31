/// Unless explicitly stated otherwise all files in this repository are licensed under the MIT License.
/// This product includes software developed at Datadog (https://www.datadoghq.com/)  Copyright 2022 Datadog, Inc.

@testable import Dogstatsd
import XCTest

final class AppTests: XCTestCase {
    
    func testDogStatsd() {
        let sender = TestDogStatsdClient()
        
        // timing
        sender.timing("some.timing_metric", value: 43 / 1000, tags: ["horse": "cart"])
        XCTAssertEqual(sender.encodedMetric, "some.timing_metric:43|ms|#horse:cart")
        
        sender.gauge("some.gauge_metric", value: 5, tags: ["baseball": "cap"])
        XCTAssertEqual(sender.encodedMetric, "some.gauge_metric:5.0|g|#baseball:cap")
        
        // gauge
        sender.gauge("some.gauge_metric", value: 0, tags: ["baseball": "cap"])
        XCTAssertEqual(sender.encodedMetric, "some.gauge_metric:0.0|g|#baseball:cap")
        
        sender.gauge("some.gauge_metric", value: 0)
        XCTAssertEqual(sender.encodedMetric, "some.gauge_metric:0.0|g")
        
        // histogram
        sender.histogram("some.histogram_metric", value: 109, tags: ["happy": "days"])
        XCTAssertEqual(sender.encodedMetric, "some.histogram_metric:109.0|h|#happy:days")
        
        sender.histogram("some.histogram_metric", value: 109)
        XCTAssertEqual(sender.encodedMetric, "some.histogram_metric:109.0|h")
        
        // distribution
        sender.distribution("some.distribution_metric", value: 7, tags: ["floppy": "hat"])
        XCTAssertEqual(sender.encodedMetric, "some.distribution_metric:7.0|d|#floppy:hat")
        
        sender.distribution("some.distribution_metric", value: 7)
        XCTAssertEqual(sender.encodedMetric, "some.distribution_metric:7.0|d")
        
        // service checks
        sender.serviceCheck(name: "neat-service",
                            status: .critical,
                            timestamp: Date(timeIntervalSince1970: 1535776860),
                            hostname: "some-host.com",
                            message: "Important message",
                            tags: ["red": "balloon"])
        XCTAssertEqual(sender.encodedMetric, "_sc|neat-service|2|d:1535776860|h:some-host.com|m:Important message|#red:balloon")
        
        sender.serviceCheck(name: "neat-service",
                            status: .ok,
                            timestamp: Date(timeIntervalSince1970: 1535776860),
                            hostname: "some-host.com",
                            message: "Important message")
        XCTAssertEqual(sender.encodedMetric, "_sc|neat-service|0|d:1535776860|h:some-host.com|m:Important message")
        
        sender.serviceCheck(name: "neat-service",
                            status: .ok,
                            timestamp: Date(timeIntervalSince1970: 1535776860),
                            message: "Important message",
                            tags: ["red": "balloon"])
        XCTAssertEqual(sender.encodedMetric, "_sc|neat-service|0|d:1535776860|m:Important message|#red:balloon")
        
        sender.serviceCheck(name: "neat-service",
                            status: .warn,
                            timestamp: Date(timeIntervalSince1970: 1535776860),
                            hostname: "some-host.com",
                            tags: ["red": "balloon"])
        XCTAssertEqual(sender.encodedMetric, "_sc|neat-service|1|d:1535776860|h:some-host.com|#red:balloon")
        
        sender.serviceCheck(name: "neat-service",
                            status: .unknown,
                            hostname: "some-host.com",
                            message: "Important message",
                            tags: ["red": "balloon", "green": "ham"])
        XCTAssertEqual(sender.encodedMetric, "_sc|neat-service|3|h:some-host.com|m:Important message|#red:balloon,green:ham")
        
        // count
        sender.increment("some.count")
        XCTAssertEqual(sender.encodedMetric, "some.count:1|c")
        
        sender.decrement("some.count")
        XCTAssertEqual(sender.encodedMetric, "some.count:-1|c")
        
        sender.count("some.count", value: 123)
        XCTAssertEqual(sender.encodedMetric, "some.count:123|c")
        
        sender.count("some.count", value: 123, tags: ["some": "tag"])
        XCTAssertEqual(sender.encodedMetric, "some.count:123|c|#some:tag")
        
        // set
        sender.set("set", value: "foo")
        XCTAssertEqual(sender.encodedMetric, "set:foo|s")
        
        sender.set("set", value: "123", tags: ["some": "tag"])
        XCTAssertEqual(sender.encodedMetric, "set:123|s|#some:tag")
    }
}

class TestStatsdSender: StatsdSender {
    
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
