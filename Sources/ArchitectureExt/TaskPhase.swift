#if canImport(ComposableArchitecture)

import ComposableArchitecture

extension TaskResult {
  /// Convert A TaskResult to AsyncPhase
  /// - Returns: AsyncPhase
  public func toAsyncPhase() -> TaskPhase<Success> {
    TaskPhase(self)
  }
}

extension Result {
  /// Transform A Result to AyncPhase
  /// - Returns: AsyncPhase
  public func toAsyncPhase() -> TaskPhase<Success> {
    TaskPhase(self)
  }
}

extension TaskPhase {
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
