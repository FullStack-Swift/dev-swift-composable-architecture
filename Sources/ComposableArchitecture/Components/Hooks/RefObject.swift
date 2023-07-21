/// A mutable object that referencing a value.
public final class RefObject<T> {
  /// A current value.
  public var current: T

  /// Creates a new ref object whose `current` property is initialized to the passed `initialValue`
  /// - Parameter initialValue: An initial value.
  public init(_ initialValue: T) {
    current = initialValue
  }
}

extension RefObject {
  public var value: T {
    current
  }
}

/// A weak Reference object refercencing a object.
public struct WeakRef<T: AnyObject> {

  /// A current object
  public weak var ref: T?

  /// Creates a new ref object whose `ref` property is initalized to the pass `ref`
  /// - Parameter ref: An initial value.
  public init(_ ref: T?) {
    self.ref = ref
  }
}
