import Foundation

/// Description
/// - Parameter fn: fn description
@discardableResult
public func withTask<Success>(
  _ fn: @escaping @Sendable () async throws -> Success
) -> Task<Success, any Error> {
  Task(operation: fn)
}

/// Description
/// - Parameter fn: fn description
@discardableResult
public func withTask<Success>(
  _ fn: @escaping @Sendable () async -> Success
) -> Task<Success, Never> {
  Task(operation: fn)
}

/// Description
/// - Parameter fn: fn description
@discardableResult
public func withMainTask<Success>(
  _ fn: @escaping @Sendable () async throws -> Success
) -> Task<Success, any Error> {
  Task { @MainActor in
    return try await fn()
  }
}

/// Description
/// - Parameter fn: fn description
@discardableResult
public func withMainTask<Success>(
  _ fn: @escaping @Sendable () async -> Success
) -> Task<Success, Never> {
  Task { @MainActor in
    return await fn()
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
      try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
      throw TimeoutError()
    }
    let success = try await group.next()!
    group.cancelAll()
    return success
  }
}
