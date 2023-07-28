import Foundation
import SwiftUI
import XCTest
@testable import ComposableArchitecture

final class HookObservableTests: XCTest {
  
  var environment: EnvironmentValues {
    var environment = EnvironmentValues()
    environment.hooksRulesAssertionDisabled = true
    return environment
  }
  
  func test_Scoped() {
    let observable = HookObservable()
    XCTAssertNil(HookObservable.current)
    observable.scoped(environment: environment) {
      XCTAssertTrue(HookObservable.current === observable)
    }
    XCTAssertNil(HookObservable.current)
  }
}
