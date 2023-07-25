/// A hook to use the most recent phase of the passed non-throwing asynchronous operation, and a `perform` function to call the it at arbitrary timing.
///
///     let (phase, refresh) = useAsyncRefresh {
///         try! await URLSession.shared.data(from: url)
///     }
///
/// - Parameter operation: A closure that produces a resulting value asynchronously.
/// - Returns: A tuple of the most recent async phase and its perform function.
@discardableResult
public func useAsyncRefresh<Output>(
  _ operation: @escaping @MainActor () async -> Output
) -> (phase: HookAsyncPhase<Output, Never>, refresher: () -> Void) {
  useHook(AsyncRefreshHook(operation: operation))
}

/// A hook to use the most recent phase of the passed throwing asynchronous operation, and a `perform` function to call the it at arbitrary timing.
///
///     let (phase, refresh) = useAsyncRefresh {
///         try await URLSession.shared.data(from: url)
///     }
///
/// - Parameter operation: A closure that produces a resulting value asynchronously.
/// - Returns: A most recent async phase.
@discardableResult
public func useAsyncRefresh<Output>(
  _ operation: @escaping @MainActor () async throws -> Output
) -> (phase: HookAsyncPhase<Output, Error>, refresher: () -> Void) {
  useHook(AsyncThrowingRefreshHook(operation: operation))
}

private struct AsyncRefreshHook<Output>: Hook {
  
  typealias State = _HookRef
  
  typealias Phase = HookAsyncPhase<Output, Never>
  
  typealias Value = (phase: Phase, refresher: () -> Void)
  
  let updateStrategy: HookUpdateStrategy? = .once
  
  let operation: @MainActor () async -> Output
  
  func makeState() -> State {
    State()
  }
  
  func value(coordinator: Coordinator) -> Value {
    let phase = coordinator.state.phase
    let refresher: () -> Void = {
      guard !coordinator.state.isDisposed else {
        return
      }
      coordinator.state.task = Task { @MainActor in
        let output = await operation()
        if !Task.isCancelled && !coordinator.state.isDisposed {
          coordinator.state.phase = .success(output)
          coordinator.updateView()
        }
      }
    }
    return (phase: phase, refresher: refresher)
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

private extension AsyncRefreshHook {
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
      task = nil
      isDisposed = true
    }
  }
}

private struct AsyncThrowingRefreshHook<Output>: Hook {
  
  typealias State = _HookRef
  
  typealias Phase = HookAsyncPhase<Output, Error>
  
  typealias Value = (phase: Phase, refresher: () -> Void)
  
  let updateStrategy: HookUpdateStrategy? = .once
  
  let operation: @MainActor () async throws -> Output
  
  func makeState() -> State {
    State()
  }
  
  func value(coordinator: Coordinator) -> Value {
    let phase = coordinator.state.phase
    let refresher: () -> Void = {
      guard !coordinator.state.isDisposed else {
        return
      }
      coordinator.state.task = Task { @MainActor in
        guard !coordinator.state.isDisposed else {
          return
        }
        let phase: HookAsyncPhase<Output, Error>
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
    return (phase: phase, refresher: refresher)
  }
  
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
  }
  
  func dispose(state: State) {
    state.isDisposed = true
  }
}

private extension AsyncThrowingRefreshHook {
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
      task = nil
      isDisposed = true
    }
  }
}
