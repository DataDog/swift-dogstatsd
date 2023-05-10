/// Unless explicitly stated otherwise all files in this repository are licensed under the MIT License.
/// This product includes software developed at Datadog (https://www.datadoghq.com/)  Copyright 2022 Datadog, Inc.

@testable import Dogstatsd
import XCTVapor

final class VaporIntegrationTests: XCTestCase {
    
    func testStartupUDP() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        
        app.dogstatsd.config = .udp(address: "127.0.0.1", port: 8125)
        app.dogstatsd.count("test", value: 1)
    }
    
    func testStartupUDS() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        
        app.dogstatsd.config = .uds(path: "/tmp/dsd.sock")
        app.dogstatsd.count("test", value: 1)
    }
    
    func testStartupDisable() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        
        app.dogstatsd.config = .disabled
        app.dogstatsd.count("test", value: 1)
    }
    
    func testGlobalTags() throws {
        let app = Application(.testing)
        defer {
            setenv("DD_ENV", "", 1)
            setenv("DD_VERSION", "", 1)
            setenv("DD_SERVICE", "", 1)
            setenv("DD_ENTITY_ID", "", 1)
            app.shutdown()
        }
        
        XCTAssertEqual(app.dogstatsd.globalTags, [])
        
        setenv("DD_ENV", "prod", 1)
        XCTAssertEqual(app.dogstatsd.globalTags, ["env:prod"])
        
        setenv("DD_VERSION", "1.2.3", 1)
        XCTAssertEqual(app.dogstatsd.globalTags.count, 2)
        XCTAssertTrue(app.dogstatsd.globalTags.contains("version:1.2.3"))
        
        setenv("DD_SERVICE", "myService", 1)
        XCTAssertEqual(app.dogstatsd.globalTags.count, 3)
        XCTAssertTrue(app.dogstatsd.globalTags.contains("service:myService"))
        
        setenv("DD_ENTITY_ID", "12345", 1)
        XCTAssertEqual(app.dogstatsd.globalTags.count, 4)
        XCTAssertTrue(app.dogstatsd.globalTags.contains("dd.internal.entity_id:12345"))
        
       
    }
}

