import Foundation
import XCTest
import ComposableArchitecture

@MainActor
final class JotailAtomTests: XCTestCase {
  func test_atom_value() {
    let id = sourceId()
    let state = atomState { context in
      0
    }
    
    let tester = RecoilTester {
      useAtomValue { context in
        let value = context.watch(state)
        return value
      }
    }
    
    XCTAssertEqual(tester.value, 0)
    
  }
}
