import Foundation


public func createStore() -> JotailStore {
  JotailStore()
}

public func getDefaultStore() -> JotailStore {
  JotailStore()
}

public func useStore(_ store: JotailStore) -> JotailStore {
  store
}

public final class JotailStore {
  
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
    store.$action.sink { action in
      coordinator.state.nextAction = action
      coordinator.updateView()
    }
    .store(in: &coordinator.state.cancellables)
    store.observable.sink(coordinator.updateView)
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
    
    var cancellables = SetCancellables()
    
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
    
    var cancellables = SetCancellables()
    
    init(initialState: StoreOf<R>) {
      state = initialState
    }
  }
}
