import Foundation
import SwiftUI
import XCTest
@testable import ComposableArchitecture

@MainActor
final class UseCallBackTest: XCTestCase {
  
  var environment: EnvironmentValues {
    var environment = EnvironmentValues()
    environment.hooksRulesAssertionDisabled = true
    return environment
  }
  
  func test_Callback() {
    let observable = HookObservable()
    observable.scoped(environment: environment) {
      let ref = useRef(0)
      let callback = useCallback {
        ref.value += 1
      }
      callback()
      XCTAssertEqual(ref.current, 1)
      
      callback()
      XCTAssertEqual(ref.current, 2)
      
      callback()
      XCTAssertEqual(ref.current, 3)
    }
  }
  
  func test_Callback_Hook_Scope_Tester() {
    HookScopeTester {
      let ref = useRef(0)
      let callback = useCallback {
        ref.value += 1
      }
      callback()
      XCTAssertEqual(ref.current, 1)
      
      callback()
      XCTAssertEqual(ref.current, 2)
      
      callback()
      XCTAssertEqual(ref.current, 3)
    }
  }
}
