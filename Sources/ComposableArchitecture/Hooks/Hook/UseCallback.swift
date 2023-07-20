/// A hook to use a side effect function that is called the number of times according to the strategy specified with `updateStrategy`.
/// Optionally the function can be cancelled when this hook is disposed or when the side-effect function is called again.
/// Note that the execution is deferred until after ohter hooks have been updated.
///
///     ```swift
///
///     let ref = useRef(0)
///     let callback = useCallback {
///       print(ref.current.description)
///       return Int.random(in: 1..<1000)
///     }
///
///     ref.current = callback()
///     print(ref.current.description)
///
///     ```
/// - Parameters:
///   - updateStrategy: A strategy that determines when to re-call the given side effect function.
///   - effect: A closure that typically represents a side-effect.
///             It is able to return a closure that to do something when this hook is unmount from the view or when the side-effect function is called again.

public typealias Callback<R> = () -> R

public typealias AsyncCallback<R> = () async throws -> R

@discardableResult
public func useCallback<Value>(
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ fn: @escaping Callback<Value>
) -> Callback<Value> {
  useHook(
    UseCallBackHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: true,
      fn: fn
    )
  )
}

@discardableResult
public func useCallBack<Value>(
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ fn: @escaping AsyncCallback<Value>
) -> AsyncCallback<Value> {
  useHook(
    UseAsyncCallBackHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: true,
      fn: fn
    )
  )
}

/// A hook to use a side effect function that is called the number of times according to the strategy specified with `updateStrategy`.
/// Optionally the function can be cancelled when this hook is unmount from the view tree or when the side-effect function is called again.
/// The signature is identical to `useEffect`, but this fires synchronously when the hook is called.
///
///     let callback = useLayoutCallback {
///       return {
///         print("Do side effects") /// doing some thing here
///       }
///     }
///
/// - Parameters:
///   - updateStrategy: A strategy that determines when to re-call the given side effect function.
///   - effect: A closure that typically represents a side-effect.
///             It is able to return a closure that to do something when this hook is unmount from the view or when the side-effect function is called again.
@discardableResult
public func useLayoutCallback<Value>(
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ fn: @escaping Callback<Value>
) -> Callback<Value> {
  useHook(
    UseCallBackHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: false,
      fn: fn
    )
  )
}

@discardableResult
public func useLayoutCallback<Value>(
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ fn: @escaping AsyncCallback<Value>
) -> AsyncCallback<Value> {
  useHook(
    UseAsyncCallBackHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: false,
      fn: fn
    )
  )
}

private struct UseCallBackHook<Value>: Hook {
  let updateStrategy: HookUpdateStrategy?
  let shouldDeferredUpdate: Bool
  let fn: Callback<Value>
  
  func makeState() -> State {
    State()
  }
  
  func value(coordinator: Coordinator) -> Callback<Value> {
    coordinator.state.fn ?? fn
  }
  
  func updateState(coordinator: Coordinator) {
    coordinator.state.fn = fn
  }
  
  func dispose(state: State) {
    state.fn = nil
  }
}

private extension UseCallBackHook {
  final class State {
    var fn: Callback<Value>?
  }
}

private struct UseAsyncCallBackHook<Value>: Hook {
  let updateStrategy: HookUpdateStrategy?
  let shouldDeferredUpdate: Bool
  let fn: AsyncCallback<Value>
  
  func makeState() -> State {
    State()
  }
  
  func value(coordinator: Coordinator) -> AsyncCallback<Value> {
    coordinator.state.fn ?? fn
  }
  
  func updateState(coordinator: Coordinator) {
    coordinator.state.fn = fn
  }
  
  func dispose(state: State) {
    state.fn = nil
  }
}

private extension UseAsyncCallBackHook {
  final class State {
    var fn: AsyncCallback<Value>?
  }
}
