import Foundation

@propertyWrapper
public struct HRef<Node> {
  
  private let _value: RefObject<Node>
  
  internal var _location: AnyLocation<((Node) -> Void)?>? = .init(value: nil)
  
  public init(wrappedValue: @escaping () -> Node) {
    _value = useRef(wrappedValue)
  }
  
  public init(wrappedValue: Node) {
    _value = useRef(wrappedValue)
  }
  
  public var wrappedValue: Node {
    get {
      _value.current
    }
    nonmutating set {
      _value.current = newValue
      if let value = _location?.value {
        value(newValue)
      }
    }
  }
  
  public var projectedValue: Self {
    self
  }
  
  public var value: RefObject<Node> {
    _value
  }
  
  public func send(_ node: Node) {
    value.current = node
  }
  
  public func onUpdated(_ onUpdate: @escaping (Node) -> Void) -> Self {
    _location?.value = onUpdate
    return self
  }
}
