import Foundation


// MARK: useRecoilValue
@MainActor public func useRecoilValue<Node: Atom>(_ initialState: Node) -> Node.Loader.Value {
  useRecoilValue {
    initialState
  }
}

// MARK: useRecoilValue
@MainActor public func useRecoilValue<Node: Atom>(
  _ initialState: @escaping() -> Node
) -> Node.Loader.Value {
  useHook(RecoilValueHook<Node>(initialState: initialState))
}

private struct RecoilValueHook<Node: Atom>: Hook {
  let initialState: () -> Node
  let updateStrategy: HookUpdateStrategy? = .once
  
  @MainActor
  func makeState() -> Ref {
    Ref(initialState: initialState())
  }
  
  init(initialState: @escaping () -> Node) {
    self.initialState = initialState
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Node.Loader.Value {
    return coordinator.state.context.watch(coordinator.state.state)
  }
  
  @MainActor
  func dispose(state: Ref) {
    state.isDisposed = true
  }
}

private extension RecoilValueHook {
  @MainActor
  final class Ref {
    var state: Node
    @_ViewContext
    var context
    var isDisposed = false
    init(initialState: Node) {
      self.state = initialState
    }
  }
}
