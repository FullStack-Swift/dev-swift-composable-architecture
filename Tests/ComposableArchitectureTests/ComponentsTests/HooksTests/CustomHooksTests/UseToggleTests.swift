import Foundation
import XCTest
import ComposableArchitecture

@MainActor
final class UseToggleTests: XCTestCase {
  
  func test_use_toggle() {
    let tester = HookTester {
      useBool(true)
    }
    
    XCTAssertEqual(tester.value.wrappedValue, true)
  }
  
  func test_use_toggle_closure() {
    let tester = HookTester {
      useBool {
        true
      }
    }
    
    XCTAssertEqual(tester.value.wrappedValue, true)
  }
}
