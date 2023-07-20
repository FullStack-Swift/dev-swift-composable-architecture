import Foundation
import Combine
import SwiftUI

/// Utilty for applying a transform to a value.
/// - Parameters:
///   - transform: The transform to apply.
///   - input: The value to be transformed.
/// - Returns: The transformed value.
public func apply<T>(_ transform: (inout T) -> Void, to input: T) -> T {
  var transformed = input
  transform(&transformed)
  return transformed
}

/// Description
/// - Parameter fn: fn description
func runAsync<Success>(_ fn: @escaping @Sendable () async throws -> Success) {
  Task(operation: fn)
}

/// Description
/// - Parameter fn: fn description
func runMainAsync<Success>(_ fn: @escaping @Sendable () async throws -> Success) {
  Task { @MainActor in
    return try await fn()
  }
}
