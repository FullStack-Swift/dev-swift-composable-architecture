import Foundation
import SwiftUI

public func useSetState<State>(_ initialState: @escaping () -> State) -> (State, (State) -> Void) {
  useHook(SetStateHook(initialState: initialState))
}

public func useSetState<State>(_ initialState: State) -> (State, (State) -> Void) {
  useSetState {
    initialState
  }
}

public func useBindingState<State>(_ initialState: @escaping () -> State) -> Binding<State> {
  let (state, setState) = useSetState(initialState)
  return Binding {
    state
  } set: { newState, transaction in
    withTransaction(transaction) {
      setState(newState)
    }
  }
}

public func useBindingState<State>(_ initialState: State) -> Binding<State> {
  let (state, setState) = useSetState(initialState)
  return Binding {
    state
  } set: { newState, transaction in
    withTransaction(transaction) {
      setState(newState)
    }
  }
}

private struct SetStateHook<State>: Hook {
  let initialState: () -> State
  var updateStrategy: HookUpdateStrategy? = .once
  
  func makeState() -> Ref {
    Ref(initialState: initialState())
  }
  
  func value(coordinator: Coordinator) -> (State, (State) -> Void) {
    let state = coordinator.state.state
    let setState: (State) -> Void = {
      coordinator.state.state = $0
      coordinator.updateView()
    }
    return (state, setState)
  }

  func dispose(state: Ref) {
    state.isDisposed = true
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
