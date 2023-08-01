public typealias Callback<R> = () -> R

public typealias AsyncCallback<R> = () async -> R

public typealias ThrowingAsyncCallback<R> = () async throws -> R

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

@discardableResult
public func useCallBack<Value>(
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ fn: @escaping ThrowingAsyncCallback<Value>
) -> ThrowingAsyncCallback<Value> {
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

@discardableResult
public func useLayoutCallback<Value>(
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ fn: @escaping ThrowingAsyncCallback<Value>
) -> ThrowingAsyncCallback<Value> {
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
  
  let fn: AsyncCallback<Value>
  
  func makeState() -> State {
    State()
  }
  
  func value(coordinator: Coordinator) -> AsyncCallback<Value> {
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
    
    var fn: AsyncCallback<Value>?
    
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
  
  let fn: ThrowingAsyncCallback<Value>
  
  func makeState() -> State {
    State()
  }
  
  func value(coordinator: Coordinator) -> ThrowingAsyncCallback<Value> {
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
    
    var fn: ThrowingAsyncCallback<Value>?
    
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
public func useParamCallBack<Param, Node: Publisher>(
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ fn: @escaping (Param) -> Node
) -> (Param) -> AsyncStream<Result<Node.Output, Node.Failure>> {
  useHook(
    UseParamPublisherCallBackHook<Param, Node>(
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
public func useLayoutParamCallBack<Param, Node: Publisher>(
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ fn: @escaping (Param) -> Node
) -> (Param) -> AsyncStream<Result<Node.Output, Node.Failure>> {
  useHook(
    UseParamPublisherCallBackHook<Param, Node>(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: false,
      fn: fn
    )
  )
}

private struct UseParamPublisherCallBackHook<Param, Node: Publisher>: Hook {
  
  typealias State = _HookRef
  
  let updateStrategy: HookUpdateStrategy?
  
  let shouldDeferredUpdate: Bool
  
  let fn: (Param) -> Node
  
  func makeState() -> State {
    State()
  }
  
  func value(coordinator: Coordinator) -> (Param) -> AsyncStream<Result<Node.Output, Node.Failure>> {
    return  { (param: Param) in
      (coordinator.state.fn ?? fn)(param).results
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

private extension UseParamPublisherCallBackHook {
  // MARK: State
  final class _HookRef {
    
    var fn: ((Param) -> Node)?
    
    var isDisposed = false
    
    func dispose() {
      fn = nil
      isDisposed = true
    }
  }
}

private extension Publisher {
  var results: AsyncStream<Result<Output, Failure>> {
    AsyncStream { continuation in
      let cancellable = map(Result.success)
        .catch { Just(.failure($0)) }
        .sink(
          receiveCompletion: { _ in
            continuation.finish()
          },
          receiveValue: { result in
            continuation.yield(result)
          }
        )
      
      continuation.onTermination = { termination in
        switch termination {
          case .cancelled:
            cancellable.cancel()
            
          case .finished:
            break
            
          @unknown default:
            break
        }
      }
    }
  }
}
#endif
