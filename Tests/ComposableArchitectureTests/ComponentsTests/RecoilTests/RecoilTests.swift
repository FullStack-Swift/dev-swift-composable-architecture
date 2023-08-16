import Foundation
import XCTest
@testable import ComposableArchitecture

@MainActor
final class RecoilTests: XCTestCase {
  
  func testValue() {
    let tester = RecoilTester {
      useRecoilValue(MValueAtom(id: "test", 0))
    }
    XCTAssertEqual(tester.value, 0)
  }

}
