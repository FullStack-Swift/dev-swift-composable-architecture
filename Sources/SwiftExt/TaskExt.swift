import Foundation

// MARK: Task sleep
extension Task where Success == Never, Failure == Never {
  /// Suspends the current task for at least the given duration
  /// in nanoseconds.
  ///
  /// If the task is canceled before the time ends,
  /// this function throws `CancellationError`.
  ///
  /// This function doesn't block the underlying thread.
  public static func sleep(seconds: Double) async throws {
    let duration = UInt64(seconds.toNanoseconds)
    try await Task.sleep(nanoseconds: duration)
  }
  
  /// Suspends the current task for at least the given duration
  /// in nanoseconds.
  ///
  /// If the task is canceled before the time ends,
  /// this function don't do anything.
  ///
  /// This function doesn't block the underlying thread.

  public static func sleepOptional(seconds: Double) async {
    let duration = UInt64(seconds.toNanoseconds)
    try? await Task.sleep(nanoseconds: duration)
  }
}

extension Task where Failure == Error {
  @discardableResult
  static func retrying(
    priority: TaskPriority? = nil,
    maxRetryCount: Int = 3,
    operation: @Sendable @escaping () async throws -> Success
  ) -> Task {
    Task(priority: priority) {
      for _ in 0..<maxRetryCount {
        try Task<Never, Never>.checkCancellation()
        do {
          return try await operation()
        } catch {
          continue
        }
      }
      try Task<Never, Never>.checkCancellation()
      return try await operation()
    }
  }
  
  
  @discardableResult
  static func retrying(
    priority: TaskPriority? = nil,
    maxRetryCount: Int = 3,
    retryDelay: TimeInterval = 1,
    operation: @Sendable @escaping () async throws -> Success
  ) -> Task {
    Task(priority: priority) {
      for _ in 0..<maxRetryCount {
        do {
          return try await operation()
        } catch {
          try await Task<Never, Never>.sleep(seconds: retryDelay)
          continue
        }
      }
      try Task<Never, Never>.checkCancellation()
      return try await operation()
    }
  }
}


/// Execute an operation in the current task subject to a timeout.
///
/// - Parameters:
///   - seconds: The duration in seconds `operation` is allowed to run before timing out.
///   - operation: The async operation to perform.
/// - Returns: Returns the result of `operation` if it completed in time.
/// - Throws: Throws ``TimedOutError`` if the timeout expires before `operation` completes.
///   If `operation` throws an error before the timeout expires, that error is propagated to the caller.
public func withTimeout<T: Sendable>(
  seconds: TimeInterval,
  body: @escaping @Sendable () async throws -> T
) async throws -> T {
  try await withThrowingTaskGroup(of: T.self) { group -> T in
    group.addTask {
      return try await body()
    }
    group.addTask {
      try await Task.sleep(seconds: seconds)
      throw CancellationError()
    }
    let success = try await group.next()!
    group.cancelAll()
    return success
  }
}
