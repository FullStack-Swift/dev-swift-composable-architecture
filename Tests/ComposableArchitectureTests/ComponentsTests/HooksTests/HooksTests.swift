import Foundation
import SwiftUI
import XCTest
@testable import ComposableArchitecture

struct TestError: Error, Equatable {
  let value: Int
}

extension XCTestCase {
  func wait(timeout seconds: TimeInterval) {
    let expectation = expectation(description: #function)
    expectation.isInverted = true
    wait(for: [expectation], timeout: seconds)
  }
  
  func sleep(timeout seconds: TimeInterval) async {
    let seconds = seconds * 1_000_000_000
    try? await Task.sleep(nanoseconds: UInt64(seconds))
  }
}

final class HookTesterTests: XCTestCase {
  
  func testValue() {
    let tester = HookTester {
      useState(0)
    }
    
    XCTAssertEqual(tester.value.wrappedValue, 0)
    
    tester.value.wrappedValue = 1
    
    XCTAssertEqual(tester.value.wrappedValue, 1)
  }
  
  func testValueHistory() {
    let tester = HookTester(0) { value in
      useMemo(.preserved(by: value)) {
        value
      }
    }
    
    tester.update(with: 1)
    tester.update(with: 2)
    tester.update(with: 3)
    
    XCTAssertEqual(tester.valueHistory, [0, 1, 2, 3])
  }
  
  func testUpdateWithParameter() {
    let tester = HookTester(0) { value in
      useMemo(.preserved(by: value)) {
        value
      }
    }
    
    XCTAssertEqual(tester.value, 0)
    
    tester.update(with: 1)
    
    XCTAssertEqual(tester.value, 1)
    
    tester.update(with: 2)
    
    XCTAssertEqual(tester.value, 2)
    
    XCTAssertEqual(tester.valueHistory, [0, 1, 2])
  }
  
  func testUpdate() {
    var value = 0
    let tester = HookTester {
      useMemo(.preserved(by: value)) {
        value
      }
    }
    
    XCTAssertEqual(tester.value, 0)
    
    value = 1
    tester.update()
    
    XCTAssertEqual(tester.value, 1)
    
    value = 2
    tester.update()
    
    XCTAssertEqual(tester.value, 2)
    
    XCTAssertEqual(tester.valueHistory, [0, 1, 2])
  }
  
  func testDispose() {
    var isCleanedup = false
    let tester = HookTester {
      useEffect(.once) {
        { isCleanedup = true }
      }
    }
    
    XCTAssertFalse(isCleanedup)
    
    tester.dispose()
    
    XCTAssertTrue(isCleanedup)
  }
  
  func testEnvironment() {
    let tester = HookTester {
      useEnvironment(\.testValue)
    } environment: {
      $0.testValue = 0
    }
    
    XCTAssertEqual(tester.value, 0)
  }
}

extension EnvironmentValues {
  @EnvironmentValue
  var testValue: Int?
}
