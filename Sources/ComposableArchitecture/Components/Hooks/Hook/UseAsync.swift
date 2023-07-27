/// A hook to use the most recent phase of asynchronous operation of the passed non-throwing function.
/// The function will be performed at the first update and will be re-performed according to the given `updateStrategy`.
///
///     let phase = useAsync(.once) {
///         try! await URLSession.shared.data(from: url)
///     }
///
/// - Parameters:
///   - updateStrategy: A strategy that determines when to re-perform the given function.
///   - operation: A closure that produces a resulting value asynchronously.
/// - Returns: A most recent async phase.
@discardableResult
public func useAsync<Output>(
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ operation: @escaping () async -> Output
) -> HookAsyncPhase<Output, Never> {
  useHook(
    AsyncHook(
      updateStrategy: updateStrategy,
      operation: operation
    )
  )
}

/// A hook to use the most recent phase of asynchronous operation of the passed throwing function.
/// The function will be performed at the first update and will be re-performed according to the given `updateStrategy`.
///
///     let phase = useAsync(.once) {
///         try await URLSession.shared.data(from: url)
///     }
///
/// - Parameters:
///   - updateStrategy: A strategy that determines when to re-perform the given function.
///   - operation: A closure that produces a resulting value asynchronously.
/// - Returns: A most recent async phase.
@discardableResult
public func useAsync<Output>(
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ operation: @escaping () async throws -> Output
) -> HookAsyncPhase<Output, Error> {
  useHook(
    AsyncThrowingHook(
      updateStrategy: updateStrategy,
      operation: operation
    )
  )
}

private struct AsyncHook<Output>: Hook {
  
  typealias State = _HookRef
  
  typealias Value = HookAsyncPhase<Output, Never>
  
  let updateStrategy: HookUpdateStrategy?
  
  let operation: () async -> Output
  
  init(
    updateStrategy: HookUpdateStrategy?,
    operation: @escaping () async -> Output
  ) {
    self.updateStrategy = updateStrategy
    self.operation = operation
  }
  
  func makeState() -> State {
    State()
  }
  
  func value(coordinator: Coordinator) -> Value {
    coordinator.state.phase
  }
  
  func updateState(coordinator: Coordinator) {
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
  
  func dispose(state: State) {
    state.dispose()
  }
}

private extension AsyncHook {
  // MARK: State
  final class _HookRef {
    
    var phase: Value = .pending
    
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

private struct AsyncThrowingHook<Output>: Hook {
  
  typealias State = _HookRef
  
  typealias Value = HookAsyncPhase<Output, Error>
  
  let updateStrategy: HookUpdateStrategy?
  
  let operation: () async throws -> Output
  
  init(
    updateStrategy: HookUpdateStrategy?,
    operation: @escaping () async throws -> Output
  ) {
    self.updateStrategy = updateStrategy
    self.operation = operation
  }
  
  func makeState() -> State {
    State()
  }
  
  func value(coordinator: Coordinator) -> Value {
    coordinator.state.phase
  }
  
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
    coordinator.state.phase = .running
    coordinator.updateView()
    coordinator.state.task = Task { @MainActor in
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
  
  func dispose(state: State) {
    state.dispose()
  }
}

private extension AsyncThrowingHook {
  // MARK: State
  final class _HookRef {
    
    var phase: Value = .pending
    
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