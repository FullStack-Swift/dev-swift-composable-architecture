import SwiftUI

/// A hook to use a `Binding<Node>` wrapping current state to be updated by setting a new state to `wrappedValue`.
/// Triggers a view update when the state has been changed.
///
///     let (count, setCount) = useSetState {
///         let initialNode = expensiveComputation()
///         return initialNode
///     }
///
///     Button("Increment") {
///         setCount(count + 1)
///     }
///
/// - Parameter initialNode: A closure creating an initial state. The closure will only be called once, during the initial render.
/// - Returns: A `Binding<Node>` wrapping current state.
public func useSetState<Node>(
  _ initialNode: @escaping () -> Node
) -> (Node, (Node) -> Void) {
  useHook(SetStateHook(initialNode: initialNode))
}

/// A hook to use a `Binding<Node>` wrapping current state to be updated by setting a new state to `wrappedValue`.
/// Triggers a view update when the state has been changed.
///
///     let count = useSetState(0)  // Binding<Int>
///
///     Button("Increment") {
///         count.wrappedValue += 1
///     }
///
/// - Parameter initialNode: An initial state.
/// - Returns: A `Binding<Node>` wrapping current state.
public func useSetState<Node>(
  _ initialNode: Node
) -> (Node, (Node) -> Void) {
  useSetState {
    initialNode
  }
}

/// A hook to use a `Binding<Node>` wrapping current state to be updated by setting a new state to `wrappedValue`.
/// Triggers a view update when the state has been changed.
///
///     let count = useBindingState {
///         let initialNode = expensiveComputation() // Int
///         return initialNode
///     }                                             // Binding<Int>
///
///     Button("Increment") {
///         count.wrappedValue += 1
///     }
///
/// - Parameter initialNode: A closure creating an initial state. The closure will only be called once, during the initial render.
/// - Returns: A `Binding<Node>` wrapping current state.
public func useBindingState<Node>(
  _ initialNode: @escaping () -> Node
) -> Binding<Node> {
  let (node, setNode) = useSetState(initialNode)
  return Binding {
    node
  } set: { newValue, transaction in
    withTransaction(transaction) {
      setNode(newValue)
    }
  }
}

/// A hook to use a `Binding<Node>` wrapping current state to be updated by setting a new state to `wrappedValue`.
/// Triggers a view update when the state has been changed.
///
///     let count = useBindingState(0)  // Binding<Int>
///
///     Button("Increment") {
///         count.wrappedValue += 1
///     }
///
/// - Parameter initialNode: An initial state.
/// - Returns: A `Binding<Node>` wrapping current state.
public func useBindingState<Node>(
  _ initialNode: Node
) -> Binding<Node> {
  useBindingState({initialNode})
}

private struct SetStateHook<Node>: Hook {

  typealias State = _HookRef
  
  typealias Value = (Node, (Node) -> Void)
  
  let updateStrategy: HookUpdateStrategy? = .once

  let initialNode: () -> Node
  
  func makeState() -> State {
    State(initialNode())
  }
  
  func value(coordinator: Coordinator) -> Value {
    let node = coordinator.state.node
    let setNode: (Node) -> Void = {
      guard !coordinator.state.isDisposed else {
        return
      }
      coordinator.state.node = $0
      coordinator.updateView()
    }
    return (node, setNode)
  }
  
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
  }

  func dispose(state: State) {
    state.dispose()
  }
}

private extension SetStateHook {
  // MARK: State
  final class _HookRef {
    
    var node: Node
    
    var isDisposed = false
    
    init(_ initialNode: Node) {
      self.node = initialNode
    }
    
    func dispose() {
      isDisposed = true
    }
  }
}
