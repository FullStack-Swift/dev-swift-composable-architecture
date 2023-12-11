/// Watches a value and triggers a callback whenever the value changed.

/// `useValueChanged` takes a valueChange callback and calls it whenever value changed. valueChange will not be called on the first useValueChanged call.

///`useValueChanged` can also be used to interpolate Whenever useValueChanged is called with a different value, calls valueChange. The value returned by useValueChanged is the latest returned value of valueChange or null.

@discardableResult
public func useValueChanged<Node: Equatable>(
  _ value: Node,
  callBack: @escaping (Node, Node) -> Void
) -> Node {
  @HRef
  var cache = value
  useLayoutEffect(.preserved(by: value)) {
    if cache != value {
      callBack(cache, value)
      cache = value
    }
    return nil
  }
  return cache
}
