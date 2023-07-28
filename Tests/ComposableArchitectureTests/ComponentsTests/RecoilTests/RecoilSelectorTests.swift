import Foundation
import XCTest
import ComposableArchitecture

@MainActor
final class RecoilSelectorTests: XCTestCase {
  
  func test_Selector() async {
    let id = sourceId()
    let tester = RecoilTester {
      useRecoilState(MStateAtom(id: id, initialState: 0))
    }
    let selectorTest = RecoilTester {
      useRecoilValue(
        selectorValue { context in
          context.watch(MStateAtom(id: id, initialState: 0)).description
        }
      )
    }
    XCTAssertEqual(tester.value.wrappedValue, 0)
    XCTAssertEqual(selectorTest.value, "0")
    
    tester.value.wrappedValue = 99
    await sleep(timeout: 1)
    XCTAssertEqual(selectorTest.value, "99")
  }
}
