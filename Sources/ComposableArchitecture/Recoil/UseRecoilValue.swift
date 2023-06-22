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
  func makeState() -> Ref {
    Ref(initialState: initialState())
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
  func dispose(state: Ref) {
    state.isDisposed = true
  }
}

private extension RecoilValueHook {
  
  final class Ref {
    var state: Node
    @RecoilViewContext
    var context
    var isDisposed = false
    init(initialState: Node) {
      self.state = initialState
    }
    
    @MainActor
    var value: Value {
      context.watch(state)
    }
  }
}
