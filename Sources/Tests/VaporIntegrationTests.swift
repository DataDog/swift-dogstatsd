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
}

