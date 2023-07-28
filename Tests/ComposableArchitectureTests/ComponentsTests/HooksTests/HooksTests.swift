import Foundation
import XCTest
import ComposableArchitecture

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

@MainActor
final class HooksTest: XCTestCase {


}
