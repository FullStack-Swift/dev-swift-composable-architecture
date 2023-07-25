/// A hook to use memoized value preserved until it is updated at the timing determined with given `updateStrategy`.
///
///     let random = useMemo(.once) {
///         Int.random(in: 0...100)
///     }
///
/// - Parameters:
///   - updateStrategy: A strategy that determines when to update the value.
///   - makeValue: A closure that to create a new value.
/// - Returns: A memoized value.
public func useMemo<Value>(
  _ updateStrategy: HookUpdateStrategy = .once,
  _ makeValue: @escaping () -> Value
) -> Value {
  useHook(
    MemoHook(
      updateStrategy: updateStrategy,
      makeValue: makeValue
    )
  )
}

private struct MemoHook<Value>: Hook {
  
  let updateStrategy: HookUpdateStrategy?
  
  let makeValue: () -> Value
  
  
  init(
    updateStrategy: HookUpdateStrategy?,
       makeValue: @escaping () -> Value
  ) {
    self.updateStrategy = updateStrategy
    self.makeValue = makeValue
  }
  
  func makeState() -> State {
    State()
  }
  
  func value(coordinator: Coordinator) -> Value {
    coordinator.state.value ?? makeValue()
  }
  
  func updateState(coordinator: Coordinator) {
    coordinator.state.value = makeValue()
  }

  func dispose(state: State) {
    
  }
}

private extension MemoHook {
  final class State {
    var value: Value?
  }
}
