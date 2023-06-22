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
  func value(coordinator: Coordinator) -> Binding<Node.Loader.Value> {
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
  func dispose(state: Ref) {
    state.isDisposed = true
  }
}

private extension RecoilStateHook {
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
