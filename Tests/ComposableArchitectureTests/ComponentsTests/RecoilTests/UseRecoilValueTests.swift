import Foundation
import XCTest
import ComposableArchitecture

@MainActor
final class UseRecoilValueTests: XCTestCase {
  
  func test_UseRecoilState() async {
    /// Expect update recoilValue when state changes.
    
    let stateId = sourceId()
    let testerState = RecoilTester {
      useRecoilState(MStateAtom(id: stateId, initialState: 0))
    }
    
    let valueId = sourceId()
    let testerValue = RecoilTester {
      useRecoilValue(MValueAtom(id: valueId) { context in
        context.watch(MStateAtom(id: stateId, initialState: 0))
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
