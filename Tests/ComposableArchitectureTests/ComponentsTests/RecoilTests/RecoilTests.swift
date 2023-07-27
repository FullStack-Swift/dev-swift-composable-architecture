import Foundation
import XCTest
import ComposableArchitecture

@MainActor
final class RecoilTests: XCTestCase {
  
  func testValue() {
    let tester = RecoilTester {
      useRecoilValue(MValueAtom(id: "test", initialState: 0))
    }
    XCTAssertEqual(tester.value, 0)
  }

}
