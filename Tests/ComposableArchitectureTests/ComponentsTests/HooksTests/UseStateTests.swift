import Foundation
import XCTest
import ComposableArchitecture

@MainActor
final class UseStateTests: XCTestCase {
  
  func test_State() {
    let tester = HookTester {
      useState(0)
    }
    XCTAssertEqual(tester.value.wrappedValue, 0)
  }
  
  func testInitialStateCreateOnceWhenGivenClosure() {
    /// Expect create value call only once time.

    // Given
    var closureCalls = 0
    
    func createState() -> Int {
      closureCalls += 1
      return 0
    }
    
    let tester = HookTester {
      useState {
        createState()
      }
    }
    
    XCTAssertEqual(closureCalls, 1)
    
    // Rerender view, starting using useHook.
    tester.update()
    
    XCTAssertEqual(closureCalls, 1)
    
    // Rerender view, starting using useHook.
    tester.update()
    
    XCTAssertEqual(closureCalls, 1)
  }
  
  func testDispose() {
    // Given
    let tester = HookTester {
      useState(0)
    }
    
    // When dispose, all hooks will remove.
    tester.dispose()
    
    // Changes value
    tester.value.wrappedValue = 99
    
    // Expect, hook value is default value
    XCTAssertEqual(tester.value.wrappedValue, 0)
    
    // Rerender view, starting using Hooks.
    tester.update()
    
    // Change value
    tester.value.wrappedValue = 99
    
    // Expect. hook value is update.
    XCTAssertEqual(tester.value.wrappedValue, 99)
  }
  
}
