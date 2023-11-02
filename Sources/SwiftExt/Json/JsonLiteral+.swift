import Foundation

extension Json: Swift.ExpressibleByStringLiteral {
  public init(stringLiteral value: StringLiteralType) {
    object = value
  }
  
  public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
    object = value
  }
  
  public init(unicodeScalarLiteral value: StringLiteralType) {
    object = value
  }
}

extension Json: Swift.ExpressibleByIntegerLiteral {
  public init(integerLiteral value: IntegerLiteralType) {
    self.init(value)
  }
}

extension Json: Swift.ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: BooleanLiteralType) {
    object = value
  }
}

extension Json: Swift.ExpressibleByFloatLiteral {
  public init(floatLiteral value: FloatLiteralType) {
    self.init(value)
  }
}

extension Json: Swift.ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (String, Any)...) {
    let dictionary = elements.reduce(into: [String: Any](), { $0[$1.0] = $1.1})
    self.object = dictionary
  }
}

extension Json: Swift.ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: Any...) {
    self.object = elements
  }
}
