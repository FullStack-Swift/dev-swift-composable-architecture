import SwiftUI

// MARK: useRecoilState
public func useRecoilState<Node: StateAtom, Context: AtomWatchableContext>(
  context: Context,
  _ initialState: Node
) -> Binding<Node.Loader.Value> {
  useRecoilState(context: context) {
    initialState
  }
}

// MARK: useRecoilState
public func useRecoilState<Node: StateAtom, Context: AtomWatchableContext>(
  context: Context,
  _ initialState: @escaping() -> Node
) -> Binding<Node.Loader.Value> {
  useHook(RecoilStateHook<Node, Context>(initialState: initialState, context: context))
}

private struct RecoilStateHook<Node: StateAtom, Context: AtomWatchableContext>: Hook {
  
  typealias Value = Binding<Node.Loader.Value>
  
  let initialState: () -> Node
  let context: Context
  let updateStrategy: HookUpdateStrategy? = .once
  
  @MainActor
  func makeState() -> Ref {
    Ref(initialState: initialState(), context: context)
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Value {
    Binding(
      get: {
        coordinator.state.context.watch(coordinator.state.state)
      },
      set: { newValue, transaction in
        assertMainThread()
        guard !coordinator.state.isDisposed else {
          return
        }
        withTransaction(transaction) {
          coordinator.state.context.set(newValue, for: coordinator.state.state)
          coordinator.updateView()
        }
      }
    )
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
  }
  
  func dispose(state: Ref) {
    state.isDisposed = true
  }
}

private extension RecoilStateHook {
  final class Ref {
    var state: Node
    let context: Context
    var isDisposed = false
    
    init(initialState: Node, context: Context) {
      self.state = initialState
      self.context = context
    }
  }
}

