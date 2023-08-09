import Foundation
import XCTest
import ComposableArchitecture

@MainActor
final class UseMemoTests: XCTestCase {
  
  func test_memo_once() {
    var value = 0
    let tester = HookTester {
      useMemo {
        value
      }
    }
    XCTAssertEqual(tester.value, 0)
    
    value = 1
    tester.update() // renderUI
    
    XCTAssertEqual(tester.value, 0)
    
    value = 2
    tester.update() // renderUI
    
    XCTAssertEqual(tester.value, 0)
  }
}
