import Foundation

struct AnyEquatable: Equatable {
  private let value: any Equatable
  private let equals: (Self) -> Bool
  
  public init<T: Equatable>(_ value: T) {
    if let key = value as? Self {
      self = key
      return
    }
    
    self.value = value
    self.equals = { other in
      value == other.value as? T
    }
  }
  
  public init(_ value: any Equatable) {
    if let key = value as? Self {
      self = key
      return
    }
    
    self.value = value
    self.equals = { other in
      areEquals(value, other.value)
    }
  }
  
  /// Returns a Boolean value indicating whether two values are equal.
  /// - Parameters:
  ///   - lhs: A value to compare.
  ///   - rhs: Another value to compare.
  /// - Returns: A Boolean value indicating whether two values are equal.
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.equals(rhs)
  }
}

public func areEquals(_ lhs: Any, _ rhs: Any) -> Bool {
  func open<A: Equatable>(_ lhs: A, _ rhs: Any) -> Bool {
    lhs == (rhs as? A)
  }
  
  func openSuperclass<A: Equatable, B: AnyObject & Equatable>(
    _ lhs: A,
    _ rhs: Any,
    _ superclass: B.Type
  ) -> Bool {
    (lhs as? B) == (rhs as? B)
  }
  
  guard let lhs = lhs as? any Equatable else {
    return false
  }
  
  var superclassStack: [AnyClass] = []
  var lhsType: Any.Type = type(of: lhs)
  
  while let superclass = _getSuperclass(lhsType) {
    superclassStack.append(superclass)
    lhsType = superclass
  }
  
  for superclass in superclassStack {
    guard let superclass = superclass as? any ((AnyObject & Equatable).Type) else {
      break
    }
    
    guard openSuperclass(lhs, rhs, superclass) else {
      continue
    }
    
    return true
  }
  
  return open(lhs, rhs)
}

extension Equatable {
  func isEqual(_ other: any Equatable) -> Bool {
    guard let other = other as? Self else {
      return other.isExactlyEqual(self)
    }
    return self == other
  }
  
  private func isExactlyEqual(_ other: any Equatable) -> Bool {
    guard let other = other as? Self else {
      return false
    }
    return self == other
  }
}

func areEqual(first: Any, second: Any) -> Bool {
  guard
    let equatableOne = first as? any Equatable,
    let equatableTwo = second as? any Equatable
  else { return false }
  
  return equatableOne.isEqual(equatableTwo)
}
