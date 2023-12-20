import SwiftUI

// MARK: - HEnvironment

/// A @propertyWrapper for useEnvironment
///
///```swift
///     @HEnvironment(\.locale)
///     var locale
///
///     @HEnvironment(\.presentationMode)
///     var presentation
///
///     @HEnvironment(\.dismiss)
///     var dismiss
///```
///
/// It's similar ``useEnvironment(_:)``, but using propertyWrapper instead.

@propertyWrapper
public struct HEnvironment<Value> {
  
  public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
    self.wrappedValue = useEnvironment(keyPath)
  }
  
  public var wrappedValue: Value
  
  public var projectedValue: Self {
    self
  }
  
  public var value: Value {
    wrappedValue
  }
}
