import Foundation
import XCTest
import ComposableArchitecture

@MainActor
final class UseInitalTests: XCTestCase {
  
  func test_use_inital() {
    var count: Int = 0
    let tester = HookTester {
      useInital {
        return {
          count += 1
        }
      }
    }
    XCTAssertEqual(count, 1)
    tester.update()
    XCTAssertEqual(count, 1)
    tester.update()
    XCTAssertEqual(count, 1)
    tester.update()
    XCTAssertEqual(count, 1)
  }
}
