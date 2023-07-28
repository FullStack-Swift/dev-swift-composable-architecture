import Foundation
import XCTest
import ComposableArchitecture

@MainActor
final class RecoilFamilyTests: XCTestCase {
  
  func test_Family() async {
    let id = sourceId()
    
    let tester = RecoilTester {
      useRecoilState(MStateAtom(id: id, initialState: 0))
    }
    
    //    let familyTester: AtomFamily<Int, MTaskAtom<String>> = recoilTaskFamily<Int, String> { param in
    //      return param.description
    //    }
    
    var family: (Int) -> RecoilParamNode<Int, MValueAtom<String>> {
      return { param in
        let selector = MValueAtom(id: sourceId(), initialState: param)
        let node = MValueAtom(id: UUID().uuidString, { context in
          let count = context.watch(MStateAtom(id: id, initialState: 0))
          let prams = context.watch(selector)
          return (param + count).description
        })
        return RecoilParamNode<Int, MValueAtom<String>>(param: param, node: node)
      }}
    
    var paramInit = 1
    let familyTester = RecoilTester {
      let node = family(paramInit)
      print("Init",node.param)
      return useRecoilValue(node)
    }
    XCTAssertEqual(tester.value.wrappedValue, 0)
    
    tester.value.wrappedValue = 99
    XCTAssertEqual(tester.value.wrappedValue, 99)
    await sleep(timeout: 1)
    XCTAssertEqual(familyTester.value, "100")
    
    tester.value.wrappedValue = 9
    
    paramInit = 101
    await sleep(timeout: 1)
    
    XCTAssertEqual(tester.value.wrappedValue, 9)
    
    await sleep(timeout: 1)
    XCTAssertEqual(familyTester.value, "10")
  }
  
  func test_TaskFamily() async {
    let id = sourceId()
    
    let tester = RecoilTester {
      useRecoilState(MStateAtom(id: id, initialState: 0))
    }
    var family: (Int) -> RecoilParamNode<Int, MTaskAtom<String>> {
      return { param in
        let node = MTaskAtom(id: sourceId()) { context in
          let count = context.watch(MStateAtom(id: id, initialState: 0))
          return (param + count).description
        }
        return RecoilParamNode<Int, MTaskAtom<String>>(param: param, node: node)
      }}
    
    var paramInit = 1
    let familyTester = RecoilTester {
      let node = family(paramInit)
      return useRecoilTask(node)
    }
    XCTAssertEqual(tester.value.wrappedValue, 0)
    
    tester.value.wrappedValue = 99
    XCTAssertEqual(tester.value.wrappedValue, 99)
    await sleep(timeout: 1)
    XCTAssertEqual(familyTester.value.value, "100")
    
    tester.value.wrappedValue = 9
    XCTAssertEqual(tester.value.wrappedValue, 9)
    paramInit = 101
    await sleep(timeout: 1)
    XCTAssertEqual(familyTester.value.value, "100")
  }
}
