import SwiftUI

/// A hook to use a `Binding<Node>` wrapping current state to be updated by setting a new state to `wrappedValue`.
/// Triggers a view update when the state has been changed.
///
///     let count = useState {
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
public func useState<Node>(
  _ initialNode: @escaping () -> Node
) -> Binding<Node> {
  useHook(StateHook(initialNode: initialNode))
}

/// A hook to use a `Binding<Node>` wrapping current state to be updated by setting a new state to `wrappedValue`.
/// Triggers a view update when the state has been changed.
///
///     let count = useState(0)  // Binding<Int>
///
///     Button("Increment") {
///         count.wrappedValue += 1
///     }
///
/// - Parameter initialNode: An initial state.
/// - Returns: A `Binding<Node>` wrapping current state.
public func useState<Node>(
  _ initialNode: Node
) -> Binding<Node> {
  useState {
    initialNode
  }
}

private struct StateHook<Node>: Hook {

  typealias State = _HookRef
  
  typealias Value = Binding<Node>
  
  var updateStrategy: HookUpdateStrategy? = .once

  let initialNode: () -> Node
  
  func makeState() -> State {
    State(initialNode())
  }
  
  func value(coordinator: Coordinator) -> Value {
    Binding(
      get: {
        coordinator.state.node
      },
      set: { newValue, transaction in
        guard !coordinator.state.isDisposed else {
          return
        }
        withTransaction(transaction) {
          coordinator.state.node = newValue
          coordinator.updateView()
        }
      }
    )
  }
  
  func updateState(coordinator: Coordinator) {
    
  }
  
  func dispose(state: State) {
    state.dispose()
  }
}

private extension StateHook {
  // MARK: State
  final class _HookRef {
    
    var node: Node
    
    var isDisposed = false
    
    init(_ initialNode: Node) {
      node = initialNode
    }
    
    func dispose() {
      isDisposed = true
    }
  }
}
