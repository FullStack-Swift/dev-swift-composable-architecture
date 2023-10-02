import Foundation
import XCTest
import ComposableArchitecture

@MainActor
final class UseDateTests: XCTestCase {
  
  func test_use_date() async {
    let tester = HookTester {
      useDate()
    }
    if let date = tester.value {
      XCTAssertEqual(date.description, Date().description)
    }
    
    await sleep(timeout: 2)
  }
}
