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

