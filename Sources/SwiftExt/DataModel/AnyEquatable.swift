import Foundation

struct AnyEquatable: Equatable {
  private let value: Any
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
  
  /// Returns a Boolean value indicating whether two values are equal.
  /// - Parameters:
  ///   - lhs: A value to compare.
  ///   - rhs: Another value to compare.
  /// - Returns: A Boolean value indicating whether two values are equal.
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.equals(rhs)
  }
}
