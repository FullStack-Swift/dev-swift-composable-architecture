public typealias ParamCallback<Param, R> = (Param) -> R

public typealias ParamAsyncCallback<Param, R> = (Param) async -> R

public typealias ParamThrowingAsyncCallback<Param, R> = (Param) async throws -> R

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
@discardableResult
public func useParamCallBack<Param, Value>(
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ fn: @escaping ParamCallback<Param, Value>
) -> ParamCallback<Param, Value> {
  useHook(
    UseParamCallBackHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: true,
      fn: fn
    )
  )
}

@discardableResult
public func useParamCallBack<Param, Value>(
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ fn: @escaping ParamAsyncCallback<Param, Value>
) -> ParamAsyncCallback<Param,Value> {
  useHook(
    UseParamAsyncCallBackHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: true,
      fn: fn
    )
  )
}

@discardableResult
public func useParamCallBack<Param, Value>(
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ fn: @escaping ParamThrowingAsyncCallback<Param, Value>
) -> ParamThrowingAsyncCallback<Param, Value> {
  useHook(
    UseParamThrowingAsyncCallBackHook(
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
public func useLayoutParamCallback<Param, Value>(
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ fn: @escaping ParamCallback<Param, Value>
) -> ParamCallback<Param, Value> {
  useHook(
    UseParamCallBackHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: false,
      fn: fn
    )
  )
}

@discardableResult
public func useLayoutParamCallback<Param, Value>(
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ fn: @escaping ParamAsyncCallback<Param, Value>
) -> ParamAsyncCallback<Param, Value> {
  useHook(
    UseParamAsyncCallBackHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: false,
      fn: fn
    )
  )
}

@discardableResult
public func useLayoutParamCallback<Param, Value>(
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ fn: @escaping ParamThrowingAsyncCallback<Param, Value>
) -> ParamThrowingAsyncCallback<Param, Value> {
  useHook(
    UseParamThrowingAsyncCallBackHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: false,
      fn: fn
    )
  )
}

private struct UseParamCallBackHook<Param, Value>: Hook {
  
  typealias State = _HookRef
  
  let updateStrategy: HookUpdateStrategy?
  
  let shouldDeferredUpdate: Bool
  
  let fn: ParamCallback<Param, Value>
  
  func makeState() -> State {
    State()
  }
  
  func value(coordinator: Coordinator) -> ParamCallback<Param, Value> {
    coordinator.state.fn ?? fn
  }
  
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
    coordinator.state.fn = fn
  }
  
  func dispose(state: State) {
    state.dispose()
  }
}

private extension UseParamCallBackHook {
  // MARK: State
  final class _HookRef {
    
    var fn: ParamCallback<Param, Value>?
    
    var isDisposed = false
    
    func dispose() {
      fn = nil
      isDisposed = true
    }
  }
}

private struct UseParamAsyncCallBackHook<Param, Value>: Hook {
  
  typealias State = _HookRef
  
  let updateStrategy: HookUpdateStrategy?
  
  let shouldDeferredUpdate: Bool
  
  let fn: ParamAsyncCallback<Param, Value>
  
  func makeState() -> State {
    State()
  }
  
  func value(coordinator: Coordinator) -> ParamAsyncCallback<Param, Value> {
    coordinator.state.fn ?? fn
  }
  
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
    coordinator.state.fn = fn
  }
  
  func dispose(state: State) {
    state.dispose()
  }
}

private extension UseParamAsyncCallBackHook {
  // MARK: State
  final class _HookRef {
    
    var fn: ParamAsyncCallback<Param, Value>?
    
    var isDisposed = false
    
    func dispose() {
      fn = nil
      isDisposed = true
    }
  }
}

private struct UseParamThrowingAsyncCallBackHook<Param, Value>: Hook {
  
  typealias State = _HookRef
  
  let updateStrategy: HookUpdateStrategy?
  
  let shouldDeferredUpdate: Bool
  
  let fn: ParamThrowingAsyncCallback<Param, Value>
  
  func makeState() -> State {
    State()
  }
  
  func value(coordinator: Coordinator) -> ParamThrowingAsyncCallback<Param, Value> {
    coordinator.state.fn ?? fn
  }
  
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
    coordinator.state.fn = fn
  }
  
  func dispose(state: State) {
    state.dispose()
  }
}

private extension UseParamThrowingAsyncCallBackHook {
  // MARK: State
  final class _HookRef {
    
    var fn: ParamThrowingAsyncCallback<Param, Value>?
    
    var isDisposed = false
    
    func dispose() {
      fn = nil
      isDisposed = true
    }
  }
}
