import Foundation

// MARK: useRecoilValue
@MainActor public func useRecoilValue<Node: Atom>(_ initialState: Node, context: AtomViewContext) -> Node.Loader.Value {
  useRecoilValue({
    initialState
  }, context: context)
}

// MARK: useRecoilValue
@MainActor public func useRecoilValue<Node: Atom>(
  _ initialState: @escaping() -> Node,
  context: AtomViewContext
) -> Node.Loader.Value {
  useHook(RecoilValueHook<Node>(initialState: initialState, context: context))
}

private struct RecoilValueHook<Node: Atom>: Hook {
  let initialState: () -> Node
  let updateStrategy: HookUpdateStrategy? = .once
  
  let context: AtomViewContext
  
  func makeState() -> Ref {
    Ref(initialState: initialState())
  }
  
  init(initialState: @escaping () -> Node, context: AtomViewContext) {
    self.initialState = initialState
    self.context = context
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Node.Loader.Value {
    return context.watch(coordinator.state.state)
  }
  
  @MainActor
  func dispose(state: Ref) {
    state.isDisposed = true
  }
}

private extension RecoilValueHook {
  final class Ref {
    var state: Node
    var isDisposed = false
    init(initialState: Node) {
      self.state = initialState
    }
  }
}
