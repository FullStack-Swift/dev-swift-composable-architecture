import Foundation
import SwiftUI

public func useSetState<Node>(
  _ initialNode: @escaping () -> Node
) -> (Node, (Node) -> Void) {
  useHook(SetStateHook(initialNode: initialNode))
}

public func useSetState<State>(
  _ initialNode: State
) -> (State, (State) -> Void) {
  useSetState {
    initialNode
  }
}

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

public func useBindingState<Node>(
  _ initialNode: Node
) -> Binding<Node> {
  useBindingState({initialNode})
}

private struct SetStateHook<Node>: Hook {

  typealias State = _HookRef
  
  typealias Value = (Node, (Node) -> Void)
  
  var updateStrategy: HookUpdateStrategy? = .once

  let initialNode: () -> Node
  
  func makeState() -> State {
    State(node: initialNode())
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
    
    init(node: Node, isDisposed: Bool = false) {
      self.node = node
      self.isDisposed = isDisposed
    }
    
    func dispose() {
      isDisposed = true
    }
  }
}
