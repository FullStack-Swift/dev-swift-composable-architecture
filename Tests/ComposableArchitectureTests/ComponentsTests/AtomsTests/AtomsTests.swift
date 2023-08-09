import Foundation
import XCTest
import ComposableArchitecture

@MainActor
final class AtomsTest: XCTestCase {
  
  
  func testValue() {
    let atom = MValueAtom(id: sourceId(), 0)
    let context = AtomTestContext()
    
    do {
      // Initial value
      let value = context.watch(atom)
      XCTAssertEqual(value, 0)
    }
    
    do {
      // Override
      context.unwatch(atom)
      context.override(atom) { _ in 99 }
      
      XCTAssertEqual(context.watch(atom), 99)
    }
  }
  
  func testUpdated() async {
    /// Expect update recoilValue when state changes.
    
    let stateId = sourceId()
    let testerState = RecoilTester {
      useRecoilState(MStateAtom(id: stateId, 0))
    }
    
    let valueId = sourceId()
    let testerValue = RecoilTester {
      useRecoilValue(MValueAtom(id: valueId) { context in
        context.watch(MStateAtom(id: stateId, 0))
      })
    }
    
    // Check default value
    XCTAssertEqual(testerState.value.wrappedValue, 0)
    
    // Check Change value
    testerState.value.wrappedValue = 99
    XCTAssertEqual(testerState.value.wrappedValue, 99)
    
    // recoilValue will not changes if it'nt update.
    XCTAssertEqual(testerValue.value, 0)
    
    // Rerender view, starting using useHook, the value will update.
    //    testerValue.update()
    
    // Delay time to update value.
    await sleep(timeout: 0.1)
    XCTAssertEqual(testerValue.value, 99)
  }
}
