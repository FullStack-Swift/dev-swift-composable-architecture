import Foundation
/// Watches a value and triggers a callback whenever the value changed.

/// `useOnChanged` takes a valueChange callback and calls it whenever value changed

///`useOnChanged` can also be used to interpolate Whenever useValueChanged is called with a different value, calls valueChange. The value returned by useValueChanged is the latest returned value of valueChange.

@discardableResult
/// ``useOnChanged``
/// - Parameters:
///   - value: value to see onChange, it's is an object extends from Equatable
///   - skip: skip number of value change
///   - effect: a call back perform onChange like View in SwiftUI. It's will be (oldValue, newValue)
/// - Returns: return latest value.
public func useOnChanged<Node: Equatable>(
  _ value: Node,
  skip: Int,
  effect: ((Node?, Node) -> Void)? = nil
) -> Node {
  @HRef
  var cache: Node? = nil /// The oldValue
  
  @HRef
  var count = useCount(.preserved(by: value))
  
  useLayouEffectChanged(.preserved(by: value)) {
    if cache != value {
      if count > skip {
        effect?(cache, value) /// (oldValue, newValue)
      }
      cache = value
    }
  }
  return cache ?? value
}

@discardableResult
public func useOnChanged<Node: Equatable>(
  _ value: Node,
  skip: Int,
  effect: (() -> Void)? = nil
) -> Node {
  useOnChanged(value, skip: skip) {_, _ in
    effect?()
  }
}

// MARK: SkipFirst like ``onChange`` in SwiftUI
@discardableResult
public func useOnChanged<Node: Equatable>(
  _ value: Node,
  skipFirst: Bool = true,
  effect: ((Node?, Node) -> Void)? = nil
) -> Node {
  useOnChanged(value, skip: 1, effect: effect)
}

@discardableResult
public func useOnChanged<Node: Equatable>(
  _ value: Node,
  skipFirst: Bool = true,
  effect: (() -> Void)? = nil
) -> Node {
  useOnChanged(value, skipFirst: skipFirst) {_, _ in
    effect?()
  }
}

