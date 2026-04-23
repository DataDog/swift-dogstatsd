@testable import Dogstatsd
import XCTest

final class StringExtensionsTests: XCTestCase {
    func testBytesCountMatchesUTF8Length() {
        XCTAssertEqual("abc".bytesCount, 3)
        XCTAssertEqual("😂".bytesCount, 4)
        XCTAssertEqual("é".bytesCount, 2)
    }
}
