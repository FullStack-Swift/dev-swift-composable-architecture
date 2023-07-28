import Foundation
import XCTest
import ComposableArchitecture

@MainActor
final class UseReducerTests: XCTestCase {
  
  @ObservableListener
  public var observer
  
  func test_useReducer() {
    
    // action
    enum Action {
      case increment
      case decrement
    }
    
    // reducer
    func reducer(state: Int, action: Action) -> Int {
      switch action {
        case .increment:
          return state + 1
        case .decrement:
          return state - 1
      }
    }
    
    // hook scope
    let scope = HookScopeTester {
      let (count, dispatch) = useReducer(reducer(state:action:), initialState: 0)
      
      XCTAssertEqual(count, 0)
      dispatch(.increment)
//      await sleep(timeout: 1)
      self.observer.sink {
        XCTAssertEqual(count, 1)
      }
    }
    scope.observer.sink(observer.send)
  }
}
