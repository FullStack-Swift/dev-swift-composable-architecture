import Foundation
import Combine

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
    coordinator.state.context.objectWillChange
      .sink(receiveValue: coordinator.updateView)
      .store(in: &coordinator.state.cancellables)
    return coordinator.state.value
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
    for cancellable in state.cancellables {
      cancellable.cancel()
    }
  }
}

private extension RecoilValueHook {
  // MARK: State
  final class State {

    @RecoilGlobalViewContext
    var context

    var node: Node
    var cancellables: Set<AnyCancellable> = []
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
