import Foundation

// MARK: HContext

/// A @propertyWrapper for useContext
///
///```swift
///
///      let todos = useContext(TodoContext.self)
///
///      @HContext
///      var context = TodoContext.self
///
///       let todos = $context.value
///```
///
///It's similar ``useContext(_:)``, but using propertyWrapper instead.

@propertyWrapper
public struct HContext<Node> {
  
  public init(wrappedValue: @escaping () -> HookContext<Node>.Type) {
    self.wrappedValue = wrappedValue()
  }
  
  public init(wrappedValue: HookContext<Node>.Type) {
    self.wrappedValue = wrappedValue
  }
  
  public var wrappedValue: HookContext<Node>.Type
  
  public var projectedValue: Self {
    self
  }
  
  public var value: Node {
    useContext(wrappedValue)
  }
}


@propertyWrapper
public struct MHContext<Node> {
  
  public var type: HookContext<Node>.Type
  
  public init(_ type: HookContext<Node>.Type) {
    self.type = type
  }
  
  
  public var projectedValue: Self {
    self
  }
  
  public var wrappedValue: Node {
    useContext(type)
  }
}
