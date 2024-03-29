import Foundation
import XCTest
@testable import ComposableArchitecture

final class UseRefTests: XCTestCase {
  
  func test_current() {
    //    Given
    let ref = RefObject(0)
    
    XCTAssertEqual(ref.value, 0)
    XCTAssertEqual(ref.current, 0)
    //    When
    ref.value = 99
    
    //    Expect
    XCTAssertEqual(ref.value, 99)
    XCTAssertEqual(ref.current, 99)
  }
}

final class WeakRefTests: XCTestCase {
  
  func test_ref() {
    // Given
    var ref: RefObject<Int>? = RefObject(0)
    
    let weakRef = WeakRefObject(ref)
    
    XCTAssertNotNil(ref)
    XCTAssertNotNil(weakRef.ref)
    // When
    ref = nil
    // Expect
    XCTAssertNil(ref)
    XCTAssertNil(weakRef.ref)
  }
}

final class SWeakRefOjbectTest: XCTestCase {
  
  func testSRef() {
//    Given
    var ref: RefObject<Int>? = RefObject(0)
    
    @SWeakRef
    var weakRef = ref
    
    XCTAssertNotNil(ref)
    XCTAssertNotNil(weakRef)
    
    // When
    ref = nil
    // Expect
    XCTAssertNil(ref)
    XCTAssertNil(weakRef)
  }
}
