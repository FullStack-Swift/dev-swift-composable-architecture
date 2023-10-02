import Foundation
import XCTest
import ComposableArchitecture

@MainActor
final class UseDisposeTests: XCTestCase {
  
  func test_use_dispose() {
    var count: Int = 0
    let tester = HookTester {
      useDispose {
        return {
          count += 1
        }
      }
    }
    XCTAssertEqual(count, 0)
    tester.update()
    XCTAssertEqual(count, 0)
    tester.update()
    XCTAssertEqual(count, 0)
    tester.update()
    XCTAssertEqual(count, 0)
    
    tester.dispose()
    XCTAssertEqual(count, 1)
    
    tester.update()
    XCTAssertEqual(count, 1)
    tester.update()
    XCTAssertEqual(count, 1)
    tester.update()
    XCTAssertEqual(count, 1)
    
    tester.dispose()
    XCTAssertEqual(count, 2)
  }
}
