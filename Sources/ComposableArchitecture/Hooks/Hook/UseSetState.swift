import Foundation

public func useSetState<State>(_ initialState: @escaping () -> State) -> (State, (State) -> Void) {
  useHook(SetStateHook(initialState: initialState))
}

public func useSetState<State>(_ initialState: State) -> (State, (State) -> Void) {
  useSetState {
    initialState
  }
}

private struct SetStateHook<State>: Hook {
  let initialState: () -> State
  var updateStrategy: HookUpdateStrategy? = .once
  
  func makeState() -> Ref {
    Ref(initialState: initialState())
  }
  
  func value(coordinator: Coordinator) -> (State, (State) -> Void) {
    (
      coordinator.state.state,
      {
      coordinator.state.state = $0
      coordinator.updateView()
      }
    )
  }
}

private extension SetStateHook {
  final class Ref {
    var state: State
    var isDisposed = false
    
    init(initialState: State) {
      state = initialState
    }
  }
}
