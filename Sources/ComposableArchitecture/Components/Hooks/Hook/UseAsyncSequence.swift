// MARK: Call operation only `updateStrategy` changes, It will updateUI status AsyncPhase.

/// A hook to use the most recent phase of asynchronous operation of the passed non-throwing function.
/// The function will be performed at the first update and will be re-performed according to the given `updateStrategy`.
///
///     let phase = useAsyncSequence(.once) {
///
///     }
///
/// - Parameters:
///   - updateStrategy: A strategy that determines when to re-perform the given function.
///   - operation: A closure that produces a resulting value asynchronously.
/// - Returns: A most recent async phase.
@discardableResult
public func useAsyncSequence<Output>(
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ operation: AsyncStream<Output>
) -> AsyncPhase<Output, Never> {
  useHook(
    AsyncSequenceHook(
      updateStrategy: updateStrategy,
      operation: operation
    )
  )
}

// MARK: Call operation only `updateStrategy` changes, It will updateUI status AsyncPhase.

/// A hook to use the most recent phase of asynchronous operation of the passed non-throwing function.
/// The function will be performed at the first update and will be re-performed according to the given `updateStrategy`.
///
///     let phase = useAsyncSequence(.once) {
///
///     }
///
/// - Parameters:
///   - updateStrategy: A strategy that determines when to re-perform the given function.
///   - operation: A closure that produces a resulting value asynchronously.
/// - Returns: A most recent async phase.
@discardableResult
public func useAsyncSequence<Output>(
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ operation: () -> AsyncStream<Output>
) -> AsyncPhase<Output, Never> {
  useHook(
    AsyncSequenceHook(
      updateStrategy: updateStrategy,
      operation: operation()
    )
  )
}

/// A hook to use the most recent phase of asynchronous operation of the passed throwing function.
/// The function will be performed at the first update and will be re-performed according to the given `updateStrategy`.
///
///     let phase = useAsync(.once) {
///
///     }
///
/// - Parameters:
///   - updateStrategy: A strategy that determines when to re-perform the given function.
///   - operation: A closure that produces a resulting value asynchronously.
/// - Returns: A most recent async phase.
@discardableResult
public func useAsyncThrowingSequence<Output>(
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ operation: AsyncThrowingStream<Output, any Error>
) -> AsyncPhase<Output, any Error> {
  useHook(
    AsyncThrowingSequenceHook(
      updateStrategy: updateStrategy,
      operation: operation
    )
  )
}

/// A hook to use the most recent phase of asynchronous operation of the passed throwing function.
/// The function will be performed at the first update and will be re-performed according to the given `updateStrategy`.
///
///     let phase = useAsync(.once) {
///
///     }
///
/// - Parameters:
///   - updateStrategy: A strategy that determines when to re-perform the given function.
///   - operation: A closure that produces a resulting value asynchronously.
/// - Returns: A most recent async phase.
@discardableResult
public func useAsyncThrowingSequence<Output>(
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ operation: () -> AsyncThrowingStream<Output, any Error>
) -> AsyncPhase<Output, any Error> {
  useHook(
    AsyncThrowingSequenceHook(
      updateStrategy: updateStrategy,
      operation: operation()
    )
  )
}

private struct AsyncSequenceHook<Output>: Hook {
  
  typealias State = _HookRef
  
  typealias Value = AsyncPhase<Output, Never>
  
  let updateStrategy: HookUpdateStrategy?
  
  let operation: AsyncStream<Output>
  
  init(
    updateStrategy: HookUpdateStrategy?,
    operation: AsyncStream<Output>
  ) {
    self.updateStrategy = updateStrategy
    self.operation = operation
  }
  
  func makeState() -> State {
    State(operation: operation)
  }
  
  func value(coordinator: Coordinator) -> Value {
    coordinator.state.phase
  }
  
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
    let sequence = coordinator.state.operation
    coordinator.state.task = Task { @MainActor in
      for await element in sequence {
        if !Task.isCancelled && !coordinator.state.isDisposed {
          coordinator.state.phase = .success(element)
          coordinator.updateView()
        }
      }
    }
  }
  
  func dispose(state: State) {
    state.dispose()
  }
}

private extension AsyncSequenceHook {
  // MARK: State
  final class _HookRef {
    
    var phase: Value = .pending
    
    let operation: AsyncStream<Output>
    
    var task: Task<Void, Never>? {
      didSet {
        oldValue?.cancel()
      }
    }
    
    init(operation: AsyncStream<Output>) {
      self.operation = operation
    }
    
    var isDisposed = false
    
    func dispose() {
      task = nil
      isDisposed = true
    }
  }
}

private struct AsyncThrowingSequenceHook<Output>: Hook {
  
  typealias State = _HookRef
  
  typealias Value = AsyncPhase<Output, any Error>
  
  let updateStrategy: HookUpdateStrategy?
  
  let operation: AsyncThrowingStream<Output, any Error>
  
  init(
    updateStrategy: HookUpdateStrategy?,
    operation: AsyncThrowingStream<Output, any Error>
  ) {
    self.updateStrategy = updateStrategy
    self.operation = operation
  }
  
  func makeState() -> State {
    State(operation: operation)
  }
  
  func value(coordinator: Coordinator) -> Value {
    coordinator.state.phase
  }
  
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
    let sequence = coordinator.state.operation
    coordinator.state.task = Task { @MainActor in
      do {
        for try await element in sequence {
          if !Task.isCancelled && !coordinator.state.isDisposed {
            coordinator.state.phase = .success(element)
            coordinator.updateView()
          }
        }
      } catch {
        if !Task.isCancelled && !coordinator.state.isDisposed {
          coordinator.state.phase = .failure(error)
          coordinator.updateView()
        }
      }
    }
  }
  
  func dispose(state: State) {
    state.dispose()
  }
}

private extension AsyncThrowingSequenceHook {
  // MARK: State
  final class _HookRef {
    
    var phase: Value = .pending
    
    let operation: AsyncThrowingStream<Output, any Error>
    
    var task: Task<Void, Never>? {
      didSet {
        oldValue?.cancel()
      }
    }
    
    init(operation: AsyncThrowingStream<Output, any Error>) {
      self.operation = operation
    }
    
    var isDisposed = false
    
    func dispose() {
      task = nil
      isDisposed = true
    }
  }
}
