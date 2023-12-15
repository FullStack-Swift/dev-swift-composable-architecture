@_spi(Internals) import ComposableArchitecture
import XCTest

fileprivate struct Model: Codable {
  var text: String = ""
  var name: String = ""
}

final class ArrayExtTests: BaseTCATestCase {
  
  func testToData() {
    let items: [Model] = arrayBuilder {
      Model(text: "A", name: "1")
      Model(text: "B", name: "2")
      Model(text: "C", name: "3")
    }
    let data = items.toData()
    
    XCTAssertNotNil(data)
    
  }
  
}
