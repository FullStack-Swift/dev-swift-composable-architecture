import Foundation
import XCTest
import ComposableArchitecture

@MainActor
final class UseReducerTests: XCTestCase {
  
//  @ObservableListener
//  public var observer
  
//  func test_useReducer() {
//    
//    // action
//    enum Action {
//      case increment
//      case decrement
//    }
//    
//    // reducer
//    func reducer(state: Int, action: Action) -> Int {
//      switch action {
//        case .increment:
//          return state + 1
//        case .decrement:
//          return state - 1
//      }
//    }
//    
//    // hook scope
//    let scope = HookScopeTester {
//      let (count, dispatch) = useReducer(reducer(state:action:), initialState: 0)
//      
//      XCTAssertEqual(count, 0)
//      dispatch(.increment)
////      await sleep(timeout: 1)
//      self.observer.sink {
//        XCTAssertEqual(count, 1)
//      }
//    }
//    scope.observer.sink(observer.send)
//  }
  
//  func test_update() {
//    func reducer(state: Int, action: Int) -> Int {
//      state + action
//    }
//    
//    let tester = HookTester {
//      useReducer(reducer, initialState: 0)
//    }
//    
//    XCTAssertEqual(tester.value.state, 0)
//    
//    tester.value.dispatch(1)
//    
//    XCTAssertEqual(tester.value.state, 1)
//    
//    tester.value.dispatch(2)
//    
//    XCTAssertEqual(tester.value.state, 3)
//    
//    tester.dispose()
//    tester.update()
//    
//    XCTAssertEqual(tester.value.state, 0)
//    
//    tester.value.dispatch(1)
//    
//    XCTAssertEqual(tester.value.state, 1)
//    
//    tester.value.dispatch(2)
//    
//    XCTAssertEqual(tester.value.state, 3)
//    
//  }
}
