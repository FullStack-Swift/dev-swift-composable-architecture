import Foundation
import XCTest
@testable import ComposableArchitecture

final class UseRefTests: XCTestCase {
  
  func test_current() {
    //    Given
    let ref = RefObject(0)
    
    XCTAssertEqual(ref.current, 0)
    XCTAssertEqual(ref.value, 0)
    //    When
    ref.current = 99
    
    //    Expect
    XCTAssertEqual(ref.current, 99)
    XCTAssertEqual(ref.value, 99)
  }
}

final class WeakRefTests: XCTestCase {
  
  func test_ref() {
    // Given
    var ref: RefObject<Int>? = RefObject(0)
    
    let weakRef = WeakRef(ref)
    XCTAssertNotNil(ref)
    XCTAssertNotNil(weakRef.ref)
    // When
    ref = nil
    // Expect
    XCTAssertNil(ref)
    XCTAssertNil(weakRef.ref)
  }
}
