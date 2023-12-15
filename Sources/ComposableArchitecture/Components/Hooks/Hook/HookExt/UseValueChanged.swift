/// Watches a value and triggers a callback whenever the value changed.

/// `useValueChanged` takes a valueChange callback and calls it whenever value changed. valueChange will not be called on the first useValueChanged call.

///`useValueChanged` can also be used to interpolate Whenever useValueChanged is called with a different value, calls valueChange. The value returned by useValueChanged is the latest returned value of valueChange or null.
///
///     @HState
///     var count = 0
///
///     useValueChanged(count) { oldValue, newValue in
///
///     }
///
///    useValueChanged(count) {
///
///    }
///
/// - Parameters:
///   - value: The value to check against when determining whether to update a state of hook.
///   - effect: A closure that typically represents a side-effect.
/// - Returns: newValue
///
@discardableResult
public func useValueChanged<Node: Equatable>(
  _ value: Node,
  effect: ((Node, Node) -> Void)? = nil
) -> Node {
  @HRef
  var cache = value
  useLayoutEffect(.preserved(by: value)) {
    if cache != value {
      effect?(cache, value)
      cache = value
    }
    return nil
  }
  return cache
}

@discardableResult
public func useValueChanged<Node: Equatable>(
  _ value: Node,
  effect: (() -> Void)? = nil
) -> Node {
  @HRef
  var cache = value
  useLayoutEffect(.preserved(by: value)) {
    if cache != value {
      effect?()
      cache = value
    }
    return nil
  }
  return cache
}

/// A hook to use memoized value preserved until it is updated at the timing determined with given `updateStrategy`.
@discardableResult
public func useOnChanged<Node: Equatable>(
  _ value: Node,
  effect: ((Node?, Node) -> Void)? = nil
) -> Node {
  @HRef
  var cache: Node? = nil
  useLayoutEffect(.preserved(by: value)) {
    if cache != value {
      effect?(cache, value)
      cache = value
    }
    return nil
  }
  return cache ?? value
}

/// A hook to use memoized value preserved until it is updated at the timing determined with given `updateStrategy`.
@discardableResult
public func useOnChanged<Node: Equatable>(
  _ value: Node,
  effect: (() -> Void)? = nil
) -> Node {
  @HRef
  var cache: Node? = nil
  useLayoutEffect(.preserved(by: value)) {
    if cache != value {
      effect?()
      cache = value
    }
    return nil
  }
  return cache ?? value
}
