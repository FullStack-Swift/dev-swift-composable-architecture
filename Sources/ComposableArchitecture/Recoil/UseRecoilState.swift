import SwiftUI
import Combine

// MARK: useRecoilState
public func useRecoilState<Node: StateAtom>(
  _ initialState: Node
) -> Binding<Node.Loader.Value> {
  useRecoilState({initialState})
}

// MARK: useRecoilState
public func useRecoilState<Node: StateAtom>(
  _ initialState: @escaping() -> Node
) -> Binding<Node.Loader.Value> {
  useHook(RecoilStateHook<Node>(initialState: initialState))
}

private struct RecoilStateHook<Node: StateAtom>: Hook {
  
  typealias Value = Binding<Node.Loader.Value>
  
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
    return Binding(
      get: {
        coordinator.state.context.watch(coordinator.state.node)
      },
      set: { newState, transaction in
        assertMainThread()
        guard !coordinator.state.isDisposed else {
          return
        }
        withTransaction(transaction) {
          coordinator.state.context.set(newState, for: coordinator.state.node)
          coordinator.updateView()
        }
      }
    )
  }
  
  @MainActor
  func dispose(state: State) {
    state.isDisposed = true
    for cancellable in state.cancellables {
      cancellable.cancel()
    }
  }
}

private extension RecoilStateHook {
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
    var value: Value {
      context.state(node)
    }
  }
}
