import Foundation

// MARK: useRecoilValue
public func useRecoilValue<Node: Atom>(
  _ initialState: Node
) -> Node.Loader.Value {
  useRecoilValue {
    initialState
  }
}

// MARK: useRecoilValue
public func useRecoilValue<Node: Atom>(
  _ initialState: @escaping() -> Node
) -> Node.Loader.Value {
  useHook(RecoilValueHook<Node>(initialState: initialState))
}

private struct RecoilValueHook<Node: Atom>: Hook {
  
  typealias Value = Node.Loader.Value
  
  let initialState: () -> Node
  let updateStrategy: HookUpdateStrategy? = .once
  
  @MainActor
  func makeState() -> State {
    State(initialState: initialState())
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Value {
    coordinator.state.value
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
  }
  
  @MainActor
  func dispose(state: State) {
    state.isDisposed = true
  }
}

private extension RecoilValueHook {
  // MARK: State
  final class State {

    @RecoilViewContext
    var context

    var node: Node
    var isDisposed = false

    init(initialState: Node) {
      self.node = initialState
    }

    /// Get current value from Recoilcontext
    @MainActor
    var value: Value {
      context.watch(node)
    }
  }
}
