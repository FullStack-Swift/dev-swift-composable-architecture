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
public func useCallback<Value>(
  _ updateStrategy: HookUpdateStrategy? = .once,
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
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ fn: @escaping AsyncReturn<Value>
) -> AsyncReturn<Value> {
  useHook(
    UseAsyncCallBackHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: true,
      fn: fn
    )
  )
}

@discardableResult
public func useCallBack<Value>(
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ fn: @escaping ThrowingAsyncReturn<Value>
) -> ThrowingAsyncReturn<Value> {
  useHook(
    UseThrowingAsyncCallBackHook(
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
  _ updateStrategy: HookUpdateStrategy? = .once,
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
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ fn: @escaping AsyncReturn<Value>
) -> AsyncReturn<Value> {
  useHook(
    UseAsyncCallBackHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: false,
      fn: fn
    )
  )
}

@discardableResult
public func useLayoutCallback<Value>(
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ fn: @escaping ThrowingAsyncReturn<Value>
) -> ThrowingAsyncReturn<Value> {
  useHook(
    UseThrowingAsyncCallBackHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: false,
      fn: fn
    )
  )
}

private struct UseCallBackHook<Value>: Hook {
  
  typealias State = _HookRef
  
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
    guard !coordinator.state.isDisposed else {
      return
    }
    coordinator.state.fn = fn
  }
  
  func dispose(state: State) {
    state.dispose()
  }
}

private extension UseCallBackHook {
  // MARK: State
  final class _HookRef {
    
    var fn: Callback<Value>?
    
    var isDisposed = false
    
    func dispose() {
      fn = nil
      isDisposed = true
    }
  }
}

private struct UseAsyncCallBackHook<Value>: Hook {
  
  typealias State = _HookRef
  
  let updateStrategy: HookUpdateStrategy?
  
  let shouldDeferredUpdate: Bool
  
  let fn: AsyncReturn<Value>
  
  func makeState() -> State {
    State()
  }
  
  func value(coordinator: Coordinator) -> AsyncReturn<Value> {
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

private extension UseAsyncCallBackHook {
  // MARK: State
  final class _HookRef {
    
    var fn: AsyncReturn<Value>?
    
    var isDisposed = false
    
    func dispose() {
      fn = nil
      isDisposed = true
    }
  }
}

private struct UseThrowingAsyncCallBackHook<Value>: Hook {
  
  typealias State = _HookRef
  
  let updateStrategy: HookUpdateStrategy?
  
  let shouldDeferredUpdate: Bool
  
  let fn: ThrowingAsyncReturn<Value>
  
  func makeState() -> State {
    State()
  }
  
  func value(coordinator: Coordinator) -> ThrowingAsyncReturn<Value> {
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

private extension UseThrowingAsyncCallBackHook {
  // MARK: State
  final class _HookRef {
    
    var fn: ThrowingAsyncReturn<Value>?
    
    var isDisposed = false
    
    func dispose() {
      fn = nil
      isDisposed = true
    }
  }
}

#if canImport(Combine)
import Combine

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
public func useCallBack<Node: Publisher>(
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ fn: @escaping () -> Node
) -> () -> AsyncStream<Result<Node.Output, Node.Failure>> {
  useHook(
    UsePublisherCallBackHook<Node>(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: true,
      fn: fn
    )
  )
}

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
public func useLayoutCallBack<Node: Publisher>(
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ fn: @escaping () -> Node
) -> () -> AsyncStream<Result<Node.Output, Node.Failure>> {
  useHook(
    UsePublisherCallBackHook<Node>(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: false,
      fn: fn
    )
  )
}

private struct UsePublisherCallBackHook<Node: Publisher>: Hook {
  
  typealias State = _HookRef
  
  let updateStrategy: HookUpdateStrategy?
  
  let shouldDeferredUpdate: Bool
  
  let fn: () -> Node
  
  func makeState() -> State {
    State()
  }
  
  func value(coordinator: Coordinator) -> () -> AsyncStream<Result<Node.Output, Node.Failure>> {
    return  {
      (coordinator.state.fn ?? fn)().results
    }
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

private extension UsePublisherCallBackHook {
  // MARK: State
  final class _HookRef {
    
    var fn: (() -> Node)?
    
    var isDisposed = false
    
    func dispose() {
      fn = nil
      isDisposed = true
    }
  }
}
#endif
