import Foundation

// MARK: HContext

/// A @propertyWrapper for useContext
///
///      let todos = useContext(TodoContext.self)
///
///      @HContext
///      var todos = TodoContext.self
///
///

@propertyWrapper
public struct HContext<Node> {
  
  public typealias Context = HookContext<Node>
  
  public init(wrappedValue: @escaping () -> Context.Type) {
    self.wrappedValue = wrappedValue()
  }
  
  public init(wrappedValue: Context.Type) {
    self.wrappedValue = wrappedValue
  }
  
  public var wrappedValue: Context.Type
  
  public var projectedValue: Node {
    useContext(wrappedValue)
  }
}
