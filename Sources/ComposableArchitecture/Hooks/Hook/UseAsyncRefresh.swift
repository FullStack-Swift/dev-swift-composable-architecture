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
) -> (phase: HookAsyncPhase<Output, Never>, refresher: @MainActor () async -> Void) {
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
) -> (phase: HookAsyncPhase<Output, Error>, refresher: @MainActor () async -> Void) {
  useHook(AsyncThrowingRefreshHook(operation: operation))
}

private struct AsyncRefreshHook<Output>: Hook {
  
  typealias Phase = HookAsyncPhase<Output, Never>
  
  let updateStrategy: HookUpdateStrategy? = .once
  let operation: @MainActor () async -> Output
  
  func makeState() -> State {
    State()
  }
  
  func value(coordinator: Coordinator) -> (phase: Phase, refresher: @MainActor () async -> Void) {
    (
      phase: coordinator.state.phase,
      refresher: {
        guard !coordinator.state.isDisposed else {
          return
        }
        
        coordinator.state.phase = .running
        
        let output = await operation()
        
        if !Task.isCancelled {
          coordinator.state.phase = .success(output)
          coordinator.updateView()
        }
      }
    )
  }
  
  func dispose(state: State) {
    state.isDisposed = true
  }
}

private extension AsyncRefreshHook {
  final class State {
    var phase = Phase.pending
    var isDisposed = false
  }
}

private struct AsyncThrowingRefreshHook<Output>: Hook {
  
  typealias Phase = HookAsyncPhase<Output, Error>
  
  let updateStrategy: HookUpdateStrategy? = .once
  let operation: @MainActor () async throws -> Output
  
  func makeState() -> State {
    State()
  }
  
  func value(coordinator: Coordinator) -> (phase: Phase, refresher: @MainActor () async -> Void) {
    (
      phase: coordinator.state.phase,
      refresher: {
        guard !coordinator.state.isDisposed else {
          return
        }
        
        coordinator.state.phase = .running
        
        let phase: HookAsyncPhase<Output, Error>
        
        do {
          let output = try await operation()
          phase = .success(output)
        }
        catch {
          phase = .failure(error)
        }
        
        if !Task.isCancelled {
          coordinator.state.phase = phase
          coordinator.updateView()
        }
      }
    )
  }
  
  func dispose(state: State) {
    state.isDisposed = true
  }
}

private extension AsyncThrowingRefreshHook {
  final class State {
    var phase = Phase.pending
    var isDisposed = false
  }
}
