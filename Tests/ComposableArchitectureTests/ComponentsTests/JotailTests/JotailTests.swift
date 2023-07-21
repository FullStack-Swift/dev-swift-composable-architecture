import Foundation
import XCTest
import ComposableArchitecture

@MainActor
final class JotailTests: XCTestCase {
  
  func testUpdateJotail() {
    let counter: MStateAtom<Int> = atom(id: "counter", 0)
    let context = AtomTestContext()
    
    do {
      XCTAssertEqual(context.watch(counter), 0)
    }
    
    do {
      context.unwatch(counter)
      context.override(counter) { _ in
        200
      }
      XCTAssertEqual(context.watch(counter), 200)
    }
    
    do {
      context[counter] = 100
      XCTAssertEqual(context.watch(counter), 100)
    }
  }
}
