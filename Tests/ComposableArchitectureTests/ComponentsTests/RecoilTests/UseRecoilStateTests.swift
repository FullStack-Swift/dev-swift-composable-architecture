import Foundation
import XCTest
import ComposableArchitecture

@MainActor
final class UseRecoilStateTests: XCTestCase {
  
  func test_UseState() async {
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
  
  @MainActor
  func test_UseState_Observable_Other_HookScope() {
    /// Expect update recoilValue when state changes.
    
    // Given
    
    let stateId = sourceId()
    let testerState = RecoilTester { // HookScope
      useRecoilState(MStateAtom(id: stateId, initialState: 0))
    }
    
    let testerStateOther = RecoilTester { // Other HookScope
      useRecoilState(MStateAtom(id: stateId, initialState: 0))
    }
    
    // Check default value
    XCTAssertEqual(testerState.value.wrappedValue, 0)
    XCTAssertEqual(testerStateOther.value.wrappedValue, 0)
    
    // Check Change value
    testerState.value.wrappedValue = 99
    XCTAssertEqual(testerState.value.wrappedValue, 99)
    
    // testerStateOther will changes if it is update.
    XCTAssertEqual(testerStateOther.value.wrappedValue, 99)
    
    // Check Change value
    testerStateOther.value.wrappedValue = 1
    XCTAssertEqual(testerStateOther.value.wrappedValue, 1)
    
    // testerStateOther will changes if it is update.
    XCTAssertEqual(testerState.value.wrappedValue, 1)
  }
  
  @MainActor
  func test_UseState_Observable_Value_Wath_State() {
    /// Expect update recoilValue when state changes.
    let stateId = sourceId()
    // Given
    let testerState = RecoilTester {
      let state = useRecoilState(MStateAtom(id: stateId, initialState: 0))
      return state
    }
    
    let testerStateOther = RecoilTester {
      let value = useRecoilState(MStateAtom(id: stateId) {
        $0.watch(MStateAtom(id: stateId, initialState: 0))
      })
      return value
    }
    // Check default value
    XCTAssertEqual(testerState.value.wrappedValue, 0)
    XCTAssertEqual(testerStateOther.value.wrappedValue, 0)
    
    // Check Change value
    testerState.value.wrappedValue = 99
    XCTAssertEqual(testerState.value.wrappedValue, 99)
    
    // testerStateOther will changes if it is update.
    XCTAssertEqual(testerStateOther.value.wrappedValue, 99)
    
    // Check Change value
    testerStateOther.value.wrappedValue = 1
    XCTAssertEqual(testerStateOther.value.wrappedValue, 1)
    
    // testerStateOther will changes if it is update.
    XCTAssertEqual(testerState.value.wrappedValue, 1)
  }
}
