import Combine
/// A hook to use the state returned by the passed `reducer`, and a `dispatch` function to send actions to update the state.
/// Triggers a view update when the state has been changed.
///
///     enum Action {
///         case increment, decrement
///     }
///
///     func reducer(state: Int, action: Action) -> Int {
///         switch action {
///             case .increment:
///                 return state + 1
///
///             case .decrement:
///                 return state - 1
///         }
///     }
///
///     let (count, dispatch) = useReducer(reducer, initialState: 0)
///
/// - Parameters:
///   - reducer: A function that to return a new state with an action.
///   - initialState: An initial state.
/// - Returns: A tuple value that has a new state returned by the passed `reducer` and a dispatch function to send actions.
public func useReducer<State, Action>(
  _ reducer: @escaping (State, Action) -> State,
  initialState: State
) -> (state: State, dispatch: (Action) -> Void) {
  useHook(ReducerHook(reducer: reducer, initialState: initialState))
}

private struct ReducerHook<State, Action>: Hook {
  
  typealias Value = (state: State, dispatch: (Action) -> Void)
  
  let updateStrategy: HookUpdateStrategy? = nil
  
  let reducer: (State, Action) -> State
  
  let initialState: State
  
  func makeState() -> _HookRef {
    _HookRef(initialState: initialState)
  }
  

  
  func value(coordinator: Coordinator) -> Value {
    let state = coordinator.state.state
    let dispatch: (Action) -> Void = { action in
      guard !coordinator.state.isDisposed else {
        return
      }
      coordinator.state.nextAction = action
      coordinator.updateView()
    }
    return (state: state, dispatch: dispatch)
  }
  
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
    guard let action = coordinator.state.nextAction else {
      return
    }
    coordinator.state.state = reducer(coordinator.state.state, action)
    coordinator.state.nextAction = nil
  }
  
  func dispose(state: _HookRef) {
    state.isDisposed = true
    state.nextAction = nil
  }
}

private extension ReducerHook {
  // MARK: State
  final class _HookRef {

    var state: State
    var nextAction: Action?
    var isDisposed = false
    
    init(initialState: State) {
      state = initialState
    }
  }
}

/// A hook to use the state returned by the passed `reducer`, and a `dispatch` function to send actions to update the state.
/// Triggers a view update when the state has been changed.
///
///     enum Action {
///         case increment, decrement
///     }
///
///     func reducer(state: inout Int, action: Action) -> Int {
///         switch action {
///             case .increment:
///                 state += 1
///
///             case .decrement:
///                 state -= 1
///         }
///     }
///
///     let (count, dispatch) = useReducer(reducer, initialState: 0)
///
/// - Parameters:
///   - reducer: A function that to return a new state with an action.
///   - initialState: An initial state.
/// - Returns: A tuple value that has a new state returned by the passed `reducer` and a dispatch function to send actions.
public func useReducer<State, Action>(
  _ reducer: @escaping (inout State, Action) -> Void,
  initialState: State
) -> (state: State, dispatch: (Action) -> Void) {
  useHook(ComposableReducerHook(reducer: reducer, initialState: initialState))
}

private struct ComposableReducerHook<State, Action>: Hook {
  
  typealias Value = (state: State, dispatch: (Action) -> Void)
  
  let updateStrategy: HookUpdateStrategy? = nil
  
  let reducer: (inout State, Action) -> Void
  
  let initialState: State

  func makeState() -> _HookRef {
    _HookRef(initialState)
  }

  func value(coordinator: Coordinator) -> Value {
    let state = coordinator.state.state
    let dispatch: (Action) -> Void = { action in
      guard !coordinator.state.isDisposed else {
        return
      }
      coordinator.state.nextAction = action
      coordinator.updateView()
    }
    return (state: state, dispatch: dispatch)
  }
  
  func updateState(coordinator: Coordinator) {
    guard let action = coordinator.state.nextAction else {
      return
    }
    reducer(&coordinator.state.state, action)
    coordinator.state.nextAction = nil
  }

  func dispose(state: _HookRef) {
    state.dispose()
  }
}

private extension ComposableReducerHook {
  // MARK: State
  final class _HookRef {
    
    var state: State
    
    var nextAction: Action?
    
    var isDisposed = false

    init(_ initialState: State) {
      state = initialState
    }
    
    func dispose() {
      isDisposed = true
      nextAction = nil
    }
  }
}
