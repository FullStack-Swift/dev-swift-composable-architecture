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

public struct WeakRef<T: AnyObject> {

  public weak var ref: T?

  public init(_ ref: T?) {
    self.ref = ref
  }
}
