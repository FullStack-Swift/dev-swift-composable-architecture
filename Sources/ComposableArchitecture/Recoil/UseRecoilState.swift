import SwiftUI

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
    Binding(
      get: {
        coordinator.state.context.watch(coordinator.state.state)
      },
      set: { newState, transaction in
        assertMainThread()
        guard !coordinator.state.isDisposed else {
          return
        }
        withTransaction(transaction) {
          coordinator.state.context.set(newState, for: coordinator.state.state)
          coordinator.updateView()
        }
      }
    )
  }
  
  @MainActor
  func dispose(state: State) {
    state.isDisposed = true
  }
}

private extension RecoilStateHook {
  // MARK: State
  final class State {

    @RecoilViewContext
    var context

    var state: Node
    var isDisposed = false
    
    init(initialState: Node) {
      self.state = initialState
    }

    /// Get current value from Recoilcontext
    var value: Value {
      context.state(state)
    }
  }
}
