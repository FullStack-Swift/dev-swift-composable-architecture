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
  let reducer: (State, Action) -> State
  let initialState: State
  let updateStrategy: HookUpdateStrategy? = nil
  
  func makeState() -> Ref {
    Ref(initialState: initialState)
  }
  
  func updateState(coordinator: Coordinator) {
    guard let action = coordinator.state.nextAction else {
      return
    }
    
    coordinator.state.state = reducer(coordinator.state.state, action)
    coordinator.state.nextAction = nil
  }
  
  func value(coordinator: Coordinator) -> (
    state: State,
    dispatch: (Action) -> Void
  ) {
    (
      state: coordinator.state.state,
      dispatch: { action in
        assertMainThread()
        
        guard !coordinator.state.isDisposed else {
          return
        }
        
        coordinator.state.nextAction = action
        coordinator.updateView()
      }
    )
  }
  
  func dispose(state: Ref) {
    state.isDisposed = true
    state.nextAction = nil
  }
}

private extension ReducerHook {
  final class Ref {
    var state: State
    var nextAction: Action?
    var isDisposed = false
    
    init(initialState: State) {
      state = initialState
    }
  }
}
