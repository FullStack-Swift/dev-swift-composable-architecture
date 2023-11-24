/// A mutable object that referencing a value.
public final class RefObject<Node> {
  /// A current value.
  public var current: Node
  
  /// Creates a new ref object whose `current` property is initialized to the passed `initialValue`
  /// - Parameter initialValue: An initial value.
  public init(_ initialValue: Node) {
    current = initialValue
  }
  
  public init(value: Node) {
    current = value
  }
}

extension RefObject {
  public var value: Node {
    get {
      current
    }
    set {
      current = newValue
    }
  }
}

extension RefObject: Equatable where Node: Equatable {
  public static func == (lhs: RefObject<Node>, rhs: RefObject<Node>) -> Bool {
    lhs.current == rhs.current
  }
}

@dynamicMemberLookup
@propertyWrapper
public struct SRefObject<Node> {
  internal let _value: RefObject<Node>
  
  public init(wrappedValue: @escaping () -> Node) {
    _value = .init(value: wrappedValue())
  }
  
  public init(wrappedValue: Node) {
    _value = .init(value: wrappedValue)
  }
  
  public var wrappedValue: Node {
    get {
      _value.value
    }
    nonmutating set {
      _value.value = newValue
    }
  }

  public var projectedValue: Self {
    self
  }
  
  public var ref: RefObject<Node> {
    _value
  }
  
  public var value: Node {
    get {
      _value.value
    }
    nonmutating set {
      _value.value = newValue
    }
  }
  
  public subscript<Value: Equatable>(
    dynamicMember keyPath: WritableKeyPath<Node, Value>
  ) -> Value {
    get {
      _value.value[keyPath: keyPath]
    }
    set {
      _value.value[keyPath: keyPath] = newValue
    }
  }
}

public struct WeakRefObject<Node: AnyObject> {
  
  /// A current object
  public weak var ref: Node?
  
  /// Creates a new ref object whose `ref` property is initalized to the pass `ref`
  /// - Parameter ref: An initial value.
  public init(_ ref: Node?) {
    self.ref = ref
  }
  
  public init(value: Node?) {
    self.ref = value
  }
  
  public var value: Node? {
    get {
      ref
    }
    
    set {
      ref = newValue
    }
  }
}

extension WeakRefObject: Equatable where Node: Equatable {}

@dynamicMemberLookup
@propertyWrapper
public struct SWeakRef<Node: AnyObject> {
  @SRefObject<WeakRefObject<Node>>
  internal var _value: WeakRefObject<Node>
  
  public init(wrappedValue: @escaping () -> Node?) {
    _value = .init(value: wrappedValue())
  }
  
  public init(wrappedValue: Node?) {
    _value = .init(value: wrappedValue)
  }
  
  public var wrappedValue: Node? {
    get {
      _value.ref
    }
    nonmutating set {
      _value.ref = newValue
    }
  }
  
  public var projectedValue: Self {
    self
  }
  
  public var value: Node? {
    get {
      _value.value
    }
    nonmutating set {
      _value.value = newValue
    }
  }
  
  public subscript<Value: Equatable>(
    dynamicMember keyPath: WritableKeyPath<Node, Value?>
  ) -> Value? {
    get {
      _value.value?[keyPath: keyPath]
    }
    set {
      _value.value?[keyPath: keyPath] = newValue
    }
  }
}
