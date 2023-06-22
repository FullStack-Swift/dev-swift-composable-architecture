import Foundation

// MARK: useRecoilValue
public func useRecoilValue<Node: ValueAtom, Context: AtomContext>(
  context: Context,
  _ initialState: Node
) -> Node.Loader.Value {
  useRecoilValue(context: context) {
    initialState
  }
}

// MARK: useRecoilValue
public func useRecoilValue<Node: ValueAtom, Context: AtomContext>(
  context: Context,
  _ initialState: @escaping() -> Node
) -> Node.Loader.Value {
  useHook(RecoilValueHook<Node, Context>(initialState: initialState, context: context))
}

private struct RecoilValueHook<Node: ValueAtom, Context: AtomContext>: Hook {
  
  typealias Value = Node.Loader.Value
  
  let initialState: () -> Node
  let context: Context
  let updateStrategy: HookUpdateStrategy? = .once
  
  @MainActor
  func makeState() -> Ref {
    Ref(initialState: initialState(),context: context)
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
    let context: Context
    var isDisposed = false
    init(initialState: Node, context: Context) {
      self.state = initialState
      self.context = context
    }
    
    @MainActor
    var value: Value {
      context.read(state)
    }
  }
}
