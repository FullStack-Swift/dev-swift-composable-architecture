import Foundation

@propertyWrapper
public struct HRef<Node> {
  
  private let value: RefObject<Node>
  
  internal var _location: AnyLocation<((Node) -> Void)?>? = .init(value: nil)
  
  public init(wrappedValue: @escaping () -> Node) {
    value = useRef(wrappedValue)
  }
  
  public init(wrappedValue: Node) {
    value = useRef(wrappedValue)
  }
  
  public var wrappedValue: Node {
    get {
      value.current
    }
    nonmutating set {
      value.current = newValue
      if let value = _location?.value {
        value(newValue)
      }
    }
  }
  
  public var projectedValue: RefObject<Node> {
    value
  }
  
  public func send(_ node: Node) {
    value.current = node
  }
  
  public func onUpdated(_ onUpdate: @escaping (Node) -> Void) -> Self {
    _location?.value = onUpdate
    return self
  }
}
