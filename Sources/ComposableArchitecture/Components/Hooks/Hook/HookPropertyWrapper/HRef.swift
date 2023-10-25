import Foundation

@propertyWrapper
public struct HRef<Node> {
  
  private let value: RefObject<Node>
  
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
    }
  }
  
  public var projectedValue: RefObject<Node> {
    value
  }
}
