import Foundation

/// A hook to use memoized value preserved until it is updated at the timing determined with given `updateStrategy` with value.
///
///     let random = useMemo {
///        /// todo
///     }
///
/// - Parameters:
///   - updateStrategy: A strategy that determines when to update the value.
///   - makeValue: A closure that to create a new value.
/// - Returns: A memoized value.
public func useMemo<Node>(
  _ condition: Bool? = false,
  _ initialNode: @escaping () -> Node
) -> Node {
  let flag = useFlagUpdated(condition)
  return useMemo(.preserved(by: flag)) {
    initialNode()
  }
}

/// A hook to use memoized value preserved until it is updated at the timing determined with given `updateStrategy` with value.
///
///     let random = useMemo {
///        /// todo
///     }
///
/// - Parameters:
///   - updateStrategy: A strategy that determines when to update the value.
///   - makeValue: A closure that to create a new value.
/// - Returns: A memoized value.
public func useMemo<Node>(
  _ initialNode: @escaping () -> Node
) -> Node where Node: Equatable {
  useMemo(.preserved(by: initialNode()), initialNode)
}

/// A hook to use memoized value preserved until it is updated at the timing determined with given `updateStrategy` with value.
///
///     let id = ...
///
///     let random = useMemo(id)
///
/// - Parameters:
///   - updateStrategy: A strategy that determines when to update the value.
///   - makeValue: A closure that to create a new value.
/// - Returns: A memoized value.
public func useMemo<Node>(
  _ initialNode: Node
) -> Node where Node: Equatable {
  useMemo(.preserved(by: initialNode), {initialNode})
}
