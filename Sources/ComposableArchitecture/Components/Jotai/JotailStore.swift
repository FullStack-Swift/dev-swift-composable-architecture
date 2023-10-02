import Foundation

/// A hook to use the state returned by the passed `reducer`, and a `dispatch` function to send actions to update the state.
/// Triggers a view update when the state has been changed.
///
///     ```swift
///     struct CounterReducer: Reducer {
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
///       var body: some ReducerOf<Self> {
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
///      let store = useReducer(initialState: CounterReducer.State(), CounterReducer())
///
///     ```
///
/// - Parameters:
///   - initialState: An initial state.
///   - reducer: A function that to return a new state with an action.
/// - Returns: A store tca.
public func useReducer<R: Reducer>(
  fileID: String = #fileID,
  line: UInt = #line,
  initialState: R.State,
  _ reducer: R
) -> StoreOf<R> {
  useHook(
    ReducerHook(
      initialState: initialState,
      reducer: reducer
    )
  )
}

public func useReducer<R: Reducer>(
  fileID: String = #fileID,
  line: UInt = #line,
  initialState: () -> R.State,
  _ reducer: R
) -> StoreOf<R> {
  useHook(
    ReducerHook(
      initialState: initialState(),
      reducer: reducer
    )
  )
}

private struct ReducerHook<R: Reducer>: Hook {
  
  typealias State = _HookRef
  
  let initialState: R.State
  let reducer: R
  let updateStrategy: HookUpdateStrategy? = nil
  
  func makeState() -> State {
    State(initialState: initialState, reducer: reducer)
  }
  
  func value(coordinator: Coordinator) -> StoreOf<R> {
    let store = coordinator.state.state
    store.$action.sink { action in
      guard !coordinator.state.isDisposed else {
        return
      }
      coordinator.updateView()
    }
    .store(in: &coordinator.state.cancellables)
    store.observable.sink(coordinator.updateView)
    return store
  }
  
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
    coordinator.state.nextAction = nil
  }
  
  func dispose(state: State) {
    state.isDisposed = true
    state.nextAction = nil
    state.cancellables.dispose()
  }
}

private extension ReducerHook {
  // MARK: State
  final class _HookRef {
    
    var state: StoreOf<R>
    
    var nextAction: R.Action?
    
    var isDisposed = false
    
    var cancellables = SetCancellables()
    
    init(initialState: R.State, reducer: R) {
      state = StoreOf<R>(initialState: initialState, reducer: { reducer })
    }
    
    func dispose() {
      isDisposed = true
      nextAction = nil
      cancellables.dispose()
    }
  }
}


/// A hook to use the state returned by the passed `reducer`, and a `dispatch` function to send actions to update the state.
/// Triggers a view update when the state has been changed.
///
///     ```swift
///     struct CounterReducer: Reducer {
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
///       var body: some ReducerOf<Self> {
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
///     let store = useStore(Store(initialState: CounterReducer.State(), CounterReducer()))
///     let useStore = useStore(store)
///
///     ```
///
/// - Parameters:
///   - store: A store tca.
/// - Returns: A store tca.
public func useStore<R: Reducer>(
  _ store: StoreOf<R>
) -> StoreOf<R> {
  useHook(StoreHook<R>(initialState: {store}))
}

public func useStore<R: Reducer>(
  _ store: @escaping () -> StoreOf<R>
) -> StoreOf<R> {
  useHook(StoreHook<R>(initialState: store))
}

private struct StoreHook<R: Reducer>: Hook {
  
  typealias State = _HookRef
  
  typealias Value = StoreOf<R>
  
  let initialState: () -> StoreOf<R>
  let updateStrategy: HookUpdateStrategy? = nil
  
  func makeState() -> State {
    State(initialState: initialState())
  }
  
  func value(coordinator: Coordinator) -> StoreOf<R> {
    let store = coordinator.state.state
    store.$action.sink { action in
      guard !coordinator.state.isDisposed else {
        return
      }
      coordinator.state.nextAction = action
      coordinator.updateView()
    }
    .store(in: &coordinator.state.cancellables)
    store.observable.sink(coordinator.updateView)
    return store
  }
  
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
    coordinator.state.nextAction = nil
  }
  
  func dispose(state: State) {
    state.dispose()
  }
}

private extension StoreHook {
  // MARK: State
  final class _HookRef {
    
    var state: StoreOf<R>
    
    var nextAction: R.Action?
    
    var isDisposed = false
    
    var cancellables = SetCancellables()
    
    init(initialState: StoreOf<R>) {
      state = initialState
    }
    
    func dispose() {
      isDisposed = true
      nextAction = nil
      cancellables.dispose()
    }
  }
}
