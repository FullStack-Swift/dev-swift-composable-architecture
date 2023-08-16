import Foundation
import XCTest
@testable import ComposableArchitecture

@MainActor
final class RecoilSelectorTests: XCTestCase {
  
  func test_recoil_value() async {
    let id = sourceId()
    let tester = RecoilTester {
      useRecoilState(MStateAtom(id: id, 0))
    }
    let selectorTest = RecoilTester {
      useRecoilValue(
        selectorValue { context in
          context.watch(MStateAtom(id: id, 0)).description
        }
      )
    }
    XCTAssertEqual(tester.value.wrappedValue, 0)
    XCTAssertEqual(selectorTest.value, "0")
    
    tester.value.wrappedValue = 99
    await sleep(timeout: 1)
    XCTAssertEqual(selectorTest.value, "99")
    
    tester.value.wrappedValue = 1
    await sleep(timeout: 1)
    XCTAssertEqual(selectorTest.value, "1")
  }
  
  func test_recoil_state_selector() async {
    let id = sourceId()
    let tester = RecoilTester {
      useRecoilState(MStateAtom(id: id, 0))
    }
    let selectorTest = RecoilTester {
      useRecoilState(
        selectorState { context in
          context.watch(MStateAtom(id: id, 0)).description
        }
      )
    }
    tester.value.wrappedValue = 99
    XCTAssertEqual(selectorTest.value.wrappedValue, "99")
    
  }
  
  func test_recoil_task_selector() async {
    
    let id = sourceId()
    let tester_state = RecoilTester {
      useRecoilState(MStateAtom(id: id, 0))
    }
    
    let tester_task = RecoilTester {
      useRecoilTask(updateStrategy: .preserved(by: tester_state.value.wrappedValue)) {
        selectorTask { context in
          let seconds = 0.1 * 1_000_000_000
          try! await Task.sleep(nanoseconds: UInt64(seconds))
          let value = context.watch(MStateAtom(id: id, 0))
          return 99 + value
        }
      }
    }
    await sleep(timeout: 1)
    XCTAssertEqual(tester_task.value.value, 99)
    
    tester_state.value.wrappedValue = 99
    tester_task.update()
    await sleep(timeout: 1)
    XCTAssertEqual(tester_task.value.value, 198)
  }
}
