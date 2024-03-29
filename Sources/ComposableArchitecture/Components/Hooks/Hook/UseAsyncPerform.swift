// MARK: Call operation only running `perform` action, It will updateUI status AsyncPhase.

/// A hook to use the most recent phase of the passed non-throwing asynchronous operation, and a `perform` function to call the it at arbitrary timing.
///
///     let (phase, perform) = useAsyncPerform {
///         try! await URLSession.shared.data(from: url)
///     }
///
/// - Parameter operation: A closure that produces a resulting value asynchronously.
/// - Returns: A tuple of the most recent async phase and its perform function.
@discardableResult
public func useAsyncPerform<Output>(
  updateStrategy: HookUpdateStrategy? = .once,
  _ operation: @escaping AsyncReturn<Output>
) -> (phase: AsyncPhase<Output, Never>, perform: AsyncCompletion) {
  useHook(
    AsyncPerformHook(
    updateStrategy: updateStrategy,
    operation: operation
    )
  )
}

/// A hook to use the most recent phase of the passed throwing asynchronous operation, and a `perform` function to call the it at arbitrary timing.
///
///     let (phase, perform) = useAsyncPerform {
///         try await URLSession.shared.data(from: url)
///     }
///
/// - Parameter operation: A closure that produces a resulting value asynchronously.
/// - Returns: A most recent async phase.
@discardableResult
public func useAsyncPerform<Output>(
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ operation: @escaping ThrowingAsyncReturn<Output>
) -> (phase: AsyncPhase<Output, Error>, perform: ThrowingAsyncCompletion) {
  useHook(
    AsyncThrowingPerformHook(
      updateStrategy: updateStrategy,
      operation: operation
    )
  )
}

private struct AsyncPerformHook<Output>: Hook {
  
  typealias State = _HookRef
  
  typealias Phase = AsyncPhase<Output, Never>
  
  typealias Value = (phase: Phase, perform: AsyncCompletion)
  
  var updateStrategy: HookUpdateStrategy? = .once
  
  let operation: AsyncReturn<Output>
  
  init(
    updateStrategy: HookUpdateStrategy? = .once,
    operation: @escaping AsyncReturn<Output>
  ) {
    self.updateStrategy = updateStrategy
    self.operation = operation
  }
  
  func makeState() -> State {
    State()
  }
  
  func value(coordinator: Coordinator) -> Value {
    let phase = coordinator.state.phase
    let perform: AsyncCompletion = {
      guard !coordinator.state.isDisposed else {
        return
      }
      coordinator.state.phase = .running
      coordinator.updateView()
      coordinator.state.task = Task { @MainActor in
        let output = await operation()
        if !Task.isCancelled && !coordinator.state.isDisposed {
          coordinator.state.phase = .success(output)
          coordinator.updateView()
        }
      }
    }
    return (phase: phase, perform: perform)
  }
  
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
  }
  
  func dispose(state: State) {
    state.dispose()
  }
}

private extension AsyncPerformHook {
  // MARK: State
  final class _HookRef {
    
    var phase: Phase = .pending
    
    var task: Task<Void, Never>? {
      didSet {
        oldValue?.cancel()
      }
    }
    
    var isDisposed = false
    
    func dispose() {
      isDisposed = true
    }
    
  }
}

private struct AsyncThrowingPerformHook<Output>: Hook {
  
  typealias State = _HookRef
  
  typealias Phase = AsyncPhase<Output, Error>
  
  typealias Value = (phase: Phase, perform: ThrowingAsyncCompletion)
  
  var updateStrategy: HookUpdateStrategy? = .once
  
  let operation: ThrowingAsyncReturn<Output>
  
  init(
    updateStrategy: HookUpdateStrategy? = .once,
    operation: @escaping ThrowingAsyncReturn<Output>
  ) {
    self.updateStrategy = updateStrategy
    self.operation = operation
  }
  
  func makeState() -> State {
    State()
  }
  
  func value(coordinator: Coordinator) -> Value {
    let phase = coordinator.state.phase
    let perform: ThrowingAsyncCompletion = {
      guard !coordinator.state.isDisposed else {
        return
      }
      coordinator.state.task = Task { @MainActor in
        guard !coordinator.state.isDisposed else {
          return
        }
        coordinator.state.phase = .running
        coordinator.updateView()
        let phase: AsyncPhase<Output, Error>
        do {
          let output = try await operation()
          phase = .success(output)
        }
        catch {
          phase = .failure(error)
        }
        if !Task.isCancelled && !coordinator.state.isDisposed {
          coordinator.state.phase = phase
          coordinator.updateView()
        }
      }
    }
    return (phase: phase, perform: perform)
  }
  
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
  }
  
  func dispose(state: State) {
    state.dispose()
  }
}

private extension AsyncThrowingPerformHook {
  // MARK: State
  final class _HookRef {
    
    var phase: Phase = .pending
    
    var task: Task<Void, Never>? {
      didSet {
        oldValue?.cancel()
      }
    }
    
    var isDisposed = false
    
    func dispose() {
      isDisposed = true
    }
  }
}
