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
  let reducer: (inout State, Action) -> Void
  let initialState: State
  let updateStrategy: HookUpdateStrategy? = nil

  func makeState() -> Ref {
    Ref(initialState: initialState)
  }

  func updateState(coordinator: Coordinator) {
    guard let action = coordinator.state.nextAction else {
      return
    }
    reducer(&coordinator.state.state, action)
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

private extension ComposableReducerHook {
  final class Ref {
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
///     ```swift
///     struct CounterReducler: ReducerProtcol {
///
///       enum Action {
///         case increment
///         case decrement
///       }
///
///       struct State {
///         var count: Int = 0
///       }
///
///       var body: some ReducerProtocolOf<Self> {
///         Reduce {state, action in
///         switch action {
///             case .increment:
///                 state.count += 1
///
///             case .decrement:
///                 state.count -= 1
///         }
///       }
///     }
///
///      let store = useReducerProtocol(initialState: CounterReducler.State(), CounterReducler())
///
///     ```
///
/// - Parameters:
///   - initialState: An initial state.
///   - reducer: A function that to return a new state with an action.
/// - Returns: A store tca.
public func useReducerProtocol<R: ReducerProtocol>(
  initialState: R.State,
  _ reducer: R
) -> StoreOf<R> {
  useHook(ReducerProtocolHook(initialState: initialState, reducer: reducer))
}

private struct ReducerProtocolHook<R: ReducerProtocol>: Hook {
  let initialState: R.State
  let reducer: R
  let updateStrategy: HookUpdateStrategy? = nil

  func makeState() -> Ref {
    Ref(initialState: initialState, reducer: reducer)
  }

  func updateState(coordinator: Coordinator) {
    coordinator.state.nextAction = nil
  }

  func value(coordinator: Coordinator) -> StoreOf<R> {
    assertMainThread()
    let store = coordinator.state.state
    store.action.sink { action in
      coordinator.state.nextAction = action
      coordinator.updateView()
    }
    .store(in: &coordinator.state.cancellables)
    store.onChangedState = {
      coordinator.updateView()
    }
    return store
  }

  func dispose(state: Ref) {
    state.isDisposed = true
    state.nextAction = nil
    for item in state.cancellables {
      item.cancel()
    }
  }
}

private extension ReducerProtocolHook {
  final class Ref {
    var state: StoreOf<R>
    var nextAction: R.Action?
    var isDisposed = false

    var cancellables = Set<AnyCancellable>()

    init(initialState: R.State, reducer: R) {
      state = StoreOf<R>(initialState: initialState, reducer: reducer)
    }
  }
}

/// A hook to use the state returned by the passed `reducer`, and a `dispatch` function to send actions to update the state.
/// Triggers a view update when the state has been changed.
///
///     ```swift
///     struct CounterReducler: ReducerProtcol {
///
///       enum Action {
///         case increment
///         case decrement
///       }
///
///       struct State {
///         var count: Int = 0
///       }
///
///       var body: some ReducerProtocolOf<Self> {
///         Reduce {state, action in
///         switch action {
///             case .increment:
///                 state.count += 1
///
///             case .decrement:
///                 state.count -= 1
///         }
///       }
///     }
///     let store = useStore(Store(initialState: CounterReducler.State(), CounterReducler()))
///     let useStore = useStore(store)
///
///     ```
///
/// - Parameters:
///   - store: A store tca.
/// - Returns: A store tca.
public func useStore<R: ReducerProtocol>(
  _ store: StoreOf<R>
) -> StoreOf<R> {
  useHook(StoreHook<R>(initialState: {store}))
}

public func useStore<R: ReducerProtocol>(
  _ store: @escaping () -> StoreOf<R>
) -> StoreOf<R> {
  useHook(StoreHook<R>(initialState: store))
}

private struct StoreHook<R: ReducerProtocol>: Hook {

  let initialState: () -> StoreOf<R>
  let updateStrategy: HookUpdateStrategy? = nil

  func makeState() -> Ref {
    Ref(initialState: initialState())
  }

  func updateState(coordinator: Coordinator) {
    coordinator.state.nextAction = nil
  }

  func value(coordinator: Coordinator) -> StoreOf<R> {
    assertMainThread()
    let store = coordinator.state.state
    store.action.sink { action in
      coordinator.state.nextAction = action
      coordinator.updateView()
    }
    .store(in: &coordinator.state.cancellables)
    store.onChangedState = {
      coordinator.updateView()
    }
    return store
  }

  func dispose(state: Ref) {
    state.isDisposed = true
    state.nextAction = nil
    for item in state.cancellables {
      item.cancel()
    }
  }
}

private extension StoreHook {
  final class Ref {
    var state: StoreOf<R>
    var nextAction: R.Action?
    var isDisposed = false

    var cancellables = Set<AnyCancellable>()

    init(initialState: StoreOf<R>) {
      state = initialState
    }
  }
}
