import SwiftUI

@propertyWrapper
public struct HEnvironment<Value> {
  
  public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
    self.wrappedValue = useEnvironment(keyPath)
  }
  
  public var wrappedValue: Value
  
  public var projectedValue: Self {
    self
  }
}
