import Foundation
import XCTest
import ComposableArchitecture

@MainActor
final class UseTimerTests: XCTestCase {
  
  func test_use_timer() async {
    let tester = HookTester {
      useCountdown(countdown: 10)
    }
    let value = tester.value
    XCTAssertEqual(value.phase.wrappedValue, .pending)
  }
}
