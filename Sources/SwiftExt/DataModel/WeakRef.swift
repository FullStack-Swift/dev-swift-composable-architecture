import Foundation
/// A weak Reference object refercencing a object.
public struct WeakRef<T: AnyObject> {
  
  /// A current object
  public weak var ref: T?
  
  /// Creates a new ref object whose `ref` property is initalized to the pass `ref`
  /// - Parameter ref: An initial value.
  public init(_ ref: T?) {
    self.ref = ref
  }
  
  public var value: T? {
    ref
  }
}
