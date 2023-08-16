import Foundation
import Combine
import XCTest
@testable import ComposableArchitecture

@MainActor
final class RecoilFamilyTests: XCTestCase {
  
  @RecoilGlobalViewContext
  var testContext
  
  func test_recoil_value_family() async {
    
    let id = sourceId()
    
    let stateAtom = selectorState(id: id, 1)
    
    let recoilValueFamily = recoilValueFamily { (param: Int, context) -> String in
      let valueAtom = context.watch(stateAtom)
      return (param + valueAtom).description
    }
    
    let tester = RecoilTester {
      useRecoilState(stateAtom)
    }
    
    let familyTester = RecoilTester(1) { param in
      let node = recoilValueFamily(param)
      return useRecoilValue(node)
    }
    
    // param recoil changes will re-render new state.
    XCTAssertEqual(familyTester.value, "2")
    
    // update new params with 100.
    familyTester.update(with: 100)
    XCTAssertEqual(familyTester.value, "101")
    
    // update new params with 10.
    familyTester.update(with: 10)
    XCTAssertEqual(familyTester.value, "11")
    
    // update new params with 0.
    familyTester.update(with: 0)
    XCTAssertEqual(familyTester.value, "1")
    
    // recoil value changes will update recoil family
    XCTAssertEqual(tester.value.wrappedValue, 1)
    
    // update recoil value it will update recoil family.
    tester.value.wrappedValue = 100
    await sleep(timeout: 1)
    XCTAssertEqual(familyTester.value, "100")
    familyTester.update() /// using current param.
    XCTAssertEqual(familyTester.value, "100")
    
    // update new params with 1.
    familyTester.update(with: 1)
    
    // update recoil value it will update recoil family.
    tester.value.wrappedValue = 10
    await sleep(timeout: 1)
    XCTAssertEqual(familyTester.value, "11")
    
    // update recoil value it will update recoil family.
    tester.value.wrappedValue = 0
    await sleep(timeout: 1)
    XCTAssertEqual(familyTester.value, "1")
    
  }
  
  func test_recoil_state_family() async {
    let id = sourceId()
    
    let stateAtom = selectorState(id: id, 1)
    
    let recoilStateFamily = recoilStateFamily { (param: Int, context) -> String in
      let value = context.watch(stateAtom)
      return (param + value).description
    }
    
    let tester = RecoilTester {
      useRecoilState(stateAtom)
    }
    
    let familyTester = RecoilTester(1) { param in
      let node = recoilStateFamily(param)
      return useRecoilState(node)
    }
    
    familyTester.value.wrappedValue = "100"
    XCTAssertEqual(familyTester.value.wrappedValue, "100")
    
    /// Update params
    familyTester.update(with: -1)
    XCTAssertEqual(familyTester.value.wrappedValue, "0")
    
    /// Update state
    tester.value.wrappedValue = -100
    XCTAssertEqual(familyTester.value.wrappedValue, "-99")
    
    familyTester.update() /// update to using current params.
    XCTAssertEqual(familyTester.value.wrappedValue, "-101")
    
    familyTester.update(with: 100)
    XCTAssertEqual(familyTester.value.wrappedValue, "0")
    
    tester.value.wrappedValue = 0
    XCTAssertEqual(familyTester.value.wrappedValue, "1") /// caculator from param init.
    
    familyTester.update()
    XCTAssertEqual(familyTester.value.wrappedValue, "100") /// caculator from current param.
  }
  
  func test_recoil_task_family() async {
    let id = sourceId()
    
    let taskAtom = selectorTask(id: id) {
      await self.sleep(timeout: 1)
      return 1
    }
    
    let recoilTaskFamily = recoilTaskFamily { (param: Int, context) -> String in
      let phase = context.watch(taskAtom.phase)
      log.warning(phase.status)
      return (param + (phase.value ?? 0)).description
    }
    
    let tester = RecoilTester {
      useRecoilTask(taskAtom)
    }
    
    let familyTester = RecoilTester(1) { param in
      let node = recoilTaskFamily(param)
      return useRecoilTask(node)
    }
    
    await self.sleep(timeout: 2)
    XCTAssertEqual(tester.value.value, 1)
    
    familyTester.update(with: 10)
    await self.sleep(timeout: 4)
    XCTAssertEqual(familyTester.value.value, "11")
  }

  func test_recoil_throwing_task_family() async {
    let id = sourceId()
    
    let taskAtom = selectorTask(id: id) {
      await self.sleep(timeout: 1)
      return 1
    }
    
    let recoilTaskFamily = recoilTaskFamily { (param: Int, context) -> String in
      let phase = context.watch(taskAtom.phase)
      return (param + (phase.value ?? 0)).description
    }
    
    let tester = RecoilTester {
      useRecoilTask(taskAtom)
    }
    
    let familyTester = RecoilTester(1) { param in
      let node = recoilTaskFamily(param)
      return useRecoilTask(node)
    }
    
    await self.sleep(timeout: 2)
    XCTAssertEqual(tester.value.value, 1)
    
    familyTester.update(with: 10)
    await self.sleep(timeout: 4)
    XCTAssertEqual(familyTester.value.value, "11")
  }
  
  func test_recoil_publisher_family() async {
    let id = sourceId()
    
    let selectorPublisher = selectorPublisher(id: id) { _ in
      Just(1)
        .delay(for: 0.15, scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    let recoilPublisherFamily = recoilPublisherFamily { (param: Int, context) -> AnyPublisher<String, Never> in
      let value = context.watch(selectorPublisher).value
      return Just((param + (value ?? 0)).description)
        .eraseToAnyPublisher()
    }
    
    let tester = RecoilTester {
      useRecoilPublisher(selectorPublisher)
    }
    
    let familyTester = RecoilTester(1) { param in
      let node = recoilPublisherFamily(param)
      return useRecoilPublisher(node)
    }
    
    await self.sleep(timeout: 0.3)
    XCTAssertEqual(tester.value.value, 1)
    
    familyTester.update(with: 10)
    await self.sleep(timeout: 1)
    XCTAssertEqual(familyTester.value.value, "11")
  }
  
  func test_recoil_publisher_family_with_state() async {
    let id = sourceId()
    
    let selectorState = selectorState(id: id) { _ in
      1
    }
    
    let recoilPublisherFamily = recoilPublisherFamily { (param: Int, context) -> AnyPublisher<String, Never> in
      let value = context.watch(selectorState)
      return Just((param + value).description)
        .eraseToAnyPublisher()
    }
    
    let tester = RecoilTester {
      useRecoilState(selectorState)
    }
    
    let familyTester = RecoilTester(1) { param in
      let node = recoilPublisherFamily(param)
      return useRecoilPublisher(node)
    }
    
    await self.sleep(timeout: 0.3)
    XCTAssertEqual(tester.value.wrappedValue, 1)
    
    familyTester.update(with: 10)
    await self.sleep(timeout: 1)
    XCTAssertEqual(familyTester.value.value, "11")
    
    tester.value.wrappedValue = 10
    await self.sleep(timeout: 0.3)
    XCTAssertEqual(tester.value.wrappedValue, 10)
    XCTAssertEqual(familyTester.value.value, "20")
  }
}
