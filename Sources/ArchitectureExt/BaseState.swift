import Foundation

public protocol BaseState: Equatable {}

public protocol BaseIDState: BaseState, Identifiable {}

extension BaseState {
  public func with(_ block: (inout Self) -> Void) -> Self {
    var clone = self
    block(&clone)
    return clone
  }
}

extension BaseIDState {
  public var idString: String {
    String(id.hashValue)
  }
}

extension Result {
  /// Creates a new phase by evaluating a async throwing closure, capturing the
  /// returned value as a success, or any thrown error as a failure.
  ///
  /// - Parameter body: A async throwing closure to evaluate.
  public init(
    catching body: @Sendable () async throws -> Success
  ) async where Failure == Error {
    do {
      let value = try await body()
      self = .success(value)
    }
    catch {
      self = .failure(error)
    }
  }
}

/// A value that represents a success, a failure, or a state in which the result of
/// asynchronous process has not yet been determined.
public enum TaskPhase<Success> {
  /// A suspending phase in which the result has not yet been determined.
  case suspending
  
  /// A success, storing a `Success` value.
  case success(Success)
  
  /// A failure, storing a `Failure` value.
  case failure(Error)
  
  /// Creates a new phase with the given result by mapping either of a `success` or
  /// a `failure`.
  ///
  /// - Parameter result: A result value to be mapped.
  public init<Failure>(_ result: Result<Success, Failure>) {
    switch result {
      case .success(let value):
        self = .success(value)
      case .failure(let error):
        self = .failure(error)
    }
  }
  
  /// Creates a new phase with the given result by mapping either of a `success` or
  /// a `failure`.
  ///
  /// - Parameter result: A result value to be mapped.
  public init(
    _ result: TaskResult<Success>
  ) {
    switch result {
      case .success(let value):
        self = .success(value)
      case .failure(let error):
        self = .failure(error)
    }
  }
  
  /// Creates a new phase by evaluating a async throwing closure, capturing the
  /// returned value as a success, or any thrown error as a failure.
  ///
  /// - Parameter body: A async throwing closure to evaluate.
  public init(
    catching body: @Sendable () async throws -> Success
  ) async {
    do {
      let value = try await body()
      self = .success(value)
    }
    catch {
      self = .failure(error)
    }
  }
  
  /// A boolean value indicating whether `self` is ``TaskPhase/suspending``.
  public var isSuspending: Bool {
    guard case .suspending = self else {
      return false
    }
    
    return true
  }
  
  /// A boolean value indicating whether `self` is ``TaskPhase/success(_:)``.
  public var isSuccess: Bool {
    guard case .success = self else {
      return false
    }
    
    return true
  }
  
  /// A boolean value indicating whether `self` is ``TaskPhase/failure(_:)``.
  public var isFailure: Bool {
    guard case .failure = self else {
      return false
    }
    
    return true
  }
  
  /// Returns the success value if `self` is ``TaskPhase/success(_:)``, otherwise returns `nil`.
  public var value: Success? {
    guard case .success(let value) = self else {
      return nil
    }
    return value
  }
  
  /// Returns the error value if `self` is ``TaskPhase/failure(_:)``, otherwise returns `nil`.
  public var error: (any Error)? {
    guard case .failure(let error) = self else {
      return nil
    }
    
    return error
  }
  
  /// Returns a new phase, mapping any success value using the given transformation.
  ///
  /// - Parameter transform: A closure that takes the success value of this instance.
  ///
  /// - Returns: An ``AsyncPhase`` instance with the result of evaluating `transform`
  ///   as the new success value if this instance represents a success.
  public func map<NewSuccess>(
    _ transform: (Success) -> NewSuccess
  ) -> TaskPhase<NewSuccess> {
    flatMap { .success(transform($0)) }
  }
  
  /// Returns a new phase, mapping any failure value using the given transformation.
  ///
  /// - Parameter transform: A closure that takes the failure value of the instance.
  ///
  /// - Returns: An ``AsyncPhase`` instance with the result of evaluating `transform` as
  ///            the new failure value if this instance represents a failure.
  public func mapError<Failure: Error>(
    _ transform: (any Error) -> Failure
  ) -> TaskPhase<Success> {
    flatMapError { .failure(transform($0)) }
  }
  
  /// Returns a new phase, mapping any success value using the given transformation
  /// and unwrapping the produced result.
  ///
  /// - Parameter transform: A closure that takes the success value of the instance.
  ///
  /// - Returns: An ``TaskPhase`` instance, either from the closure or the previous
  ///            ``TaskPhase/failure(_:)``.
  public func flatMap<NewSuccess>(
    _ transform: (Success) -> TaskPhase<NewSuccess>
  ) -> TaskPhase<NewSuccess> {
    switch self {
      case .suspending:
          .suspending
      case .success(let value):
        transform(value)
      case .failure(let error):
          .failure(error)
    }
  }
  
  /// Returns a new phase, mapping any failure value using the given transformation
  /// and unwrapping the produced result.
  ///
  /// - Parameter transform: A closure that takes the failure value of the instance.
  ///
  /// - Returns: An ``TaskPhase`` instance, either from the closure or the previous
  ///            ``TaskPhase/success(_:)``.
  public func flatMapError(
    _ transform: (any Error) -> TaskPhase<Success>
  ) -> TaskPhase<Success> {
    switch self {
      case .suspending:
          .suspending
      case .success(let value):
          .success(value)
      case .failure(let error):
        transform(error)
    }
  }
}

extension TaskPhase {
  /// The status using in HookUpdateStrategy to order handle response phase.
  public enum StatusPhase: Hashable, Equatable {
    /// Represents a suspending phase.
    case suspending
    /// Represents a success phase.
    case success
    /// Represents a failure phase.
    case failure
  }
  
  /// the status of phase which we can compare to update HookUpdateStrategy.
  public var status: StatusPhase {
    switch self {
      case .suspending:
          .suspending
      case .success(_):
          .success
      case .failure(_):
          .failure
    }
  }
}


extension TaskPhase {
  /// Merge AysncPhase
  /// We receive Success and show to the view only If 2 phase is Success.
  /// - Parameter other: other AsyncPhase
  /// - Returns: AsyncPhase
  public func merge(_ other: Self) -> TaskPhase<(Success, Success)> {
    switch (self, other) {
      case (.failure(let error), _):
        return .failure(error)
      case (_, .failure(let error)):
        return .failure(error)
      case (.suspending, _):
        return .suspending
      case (_, .suspending):
        return .suspending
      case (.success(let thisData), .success(let otherData)):
        return .success((thisData, otherData))
    }
  }
}

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
