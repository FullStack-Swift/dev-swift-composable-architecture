#if canImport(ComposableArchitecture)

import ComposableArchitecture

// MARK: Transform to TaskPhase

extension TaskResult {
  
  /// Transform A TaskResult to TaskPhase
  ///
  ///       let taskResult: TaskResult<Success> = ...
  ///       let taskPhase = taskResult.toTaskPhase()
  ///
  /// - Returns: TaskPhase
  public func toTaskPhase() -> TaskPhase<Success> {
    TaskPhase(self)
  }
}

extension Result {
  
  /// Transform A Result to TaskPhase
  ///
  ///     let result: Result<Success, any Error> = ...
  ///     let taskPhase = result.toTaskPhase()
  ///
  /// - Returns: TaskPhase
  public func toTaskPhase() -> TaskPhase<Success> {
    TaskPhase(self)
  }
}

// MARK: TaskPhase transform to other.

extension TaskPhase {
  
  /// Transform A TaskPhase to AsyncPhase ( ``Atom``)
  ///
  ///     let taskPhase: TaskPhase<Success> = ...
  ///     let asyncPhase = taskPhase.toAsyncPhase()
  ///
  /// - Returns: AsyncPhase
  
  public func toAsyncPhase() -> AsyncPhase<Success, any Error> {
    switch self {
      case .suspending:
          .suspending
      case .success(let success):
          .success(success)
      case .failure(let error):
          .failure(error)
    }
  }
  
  /// Transform A TaskPhase to HookAsyncPhase
  ///
  ///     let taskPhase: TaskPhase<Success> = ...
  ///     let hookAsyncPhase = taskPhase.toHookAsyncPhase()
  ///
  ///  - Returns: HookAsyncPhase
  
  public func toHookAsyncPhase() -> HookAsyncPhase<Success, any Error> {
    switch self {
      case .suspending:
          .pending
      case .success(let success):
          .success(success)
      case .failure(let error):
          .failure(error)
    }
  }
}

#endif

extension AsyncStream {
  
}

extension AsyncThrowingStream {
  
}
