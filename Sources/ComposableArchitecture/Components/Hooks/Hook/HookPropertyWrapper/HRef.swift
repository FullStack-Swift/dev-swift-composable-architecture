import Foundation

// MARK: - HRef

/// A @propertyWrapper for useRef.
///
///
/// ```swift
///
///     @HRef var page = 0
///
///     @HRef<Int> var page = { 0 }
///
/// ```
///
/// It's similar ``useRef(_:)-6e7ga``, but using propertyWrapper instead.

@propertyWrapper
public struct HRef<Node> {
  
  private let _value: RefObject<Node>
  
  @SAnyRef
  internal var _ref: ((Node) -> Void)? = nil
  
  public init(wrappedValue: @escaping () -> Node) {
    _value = useRef(wrappedValue)
  }
  
  public init(wrappedValue: Node) {
    _value = useRef(wrappedValue)
  }
  
  public var wrappedValue: Node {
    get {
      _value.value
    }
    nonmutating set {
      _value.value = newValue
      if let value = _ref {
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
    value.value = node
  }
  
  public func onUpdated(_ onUpdate: @escaping (Node) -> Void) -> Self {
    _ref = onUpdate
    return self
  }
}
