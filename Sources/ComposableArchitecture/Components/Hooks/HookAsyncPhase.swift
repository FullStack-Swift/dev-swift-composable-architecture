/// An immutable representation of the most recent asynchronous operation phase.
@frozen
public enum HookAsyncPhase<Success, Failure: Error> {
  /// Represents a pending phase meaning that the operation has not been started.
  case pending
  
  /// Represents a running phase meaning that the operation has been started, but has not yet provided a result.
  case running
  
  /// Represents a success phase meaning that the operation provided a value with success.
  case success(Success)
  
  /// Represents a failure phase meaning that the operation provided an error with failure.
  case failure(Failure)
  
  /// Creates a new phase with the given result by mapping either of a `success` or
  /// a `failure`.
  ///
  /// - Parameter result: A result value to be mapped.
  public init(_ result: Result<Success, Failure>) {
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
  ) where Failure == Error {
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
    catching body: () async throws -> Success
  ) async where Failure == Error {
    do {
      let value = try await body()
      self = .success(value)
    }
    catch {
      self = .failure(error)
    }
  }
  
  /// Returns a Boolean value indicating whether this instance represents a `pending`.
  public var isPending: Bool {
    guard case .pending = self else {
      return false
    }
    return true
  }
  
  /// Returns a Boolean value indicating whether this instance represents a `running`.
  public var isRunning: Bool {
    guard case .running = self else {
      return false
    }
    return true
  }
  
  /// Returns a Boolean value indicating whether this instance represents a `success`.
  public var isSuccess: Bool {
    guard case .success = self else {
      return false
    }
    return true
  }
  
  /// Returns a Boolean value indicating whether this instance represents a `failure`.
  public var isFailure: Bool {
    guard case .failure = self else {
      return false
    }
    return true
  }
  
  /// Returns a success value if this instance is `success`, otherwise returns `nil`.
  public var value: Success? {
    guard case .success(let value) = self else {
      return nil
    }
    return value
  }
  
  /// Returns an error if this instance is `failure`, otherwise returns `nil`.
  public var error: Failure? {
    guard case .failure(let error) = self else {
      return nil
    }
    return error
  }
  
  /// Returns a result converted from the phase.
  /// If this instance represents a `pending` or a `running`, this returns nil.
  public var result: Result<Success, Failure>? {
    switch self {
      case .pending, .running:
        return nil
        
      case .success(let success):
        return .success(success)
        
      case .failure(let error):
        return .failure(error)
    }
  }
  
  /// Returns a taskResult converted from the phase.
  /// if this instance represents a `pending` or a `runiing`, this returns nil.
  public var taskResult: TaskResult<Success>? {
    if let result {
      return TaskResult(result)
    } else {
      return nil
    }
  }
  
  /// Returns a new phase, mapping any success value using the given transformation.
  /// - Parameter transform: A closure that takes the success value of this instance.
  /// - Returns: An `AsyncPhase` instance with the result of evaluating `transform` as the new success value if this instance represents a success.
  public func map<NewSuccess>(
    _ transform: (Success) -> NewSuccess
  ) -> HookAsyncPhase<NewSuccess, Failure> {
    flatMap { .success(transform($0)) }
  }
  
  /// Returns a new result, mapping any failure value using the given transformation.
  /// - Parameter transform: A closure that takes the failure value of the instance.
  /// - Returns: An `AsyncPhase` instance with the result of evaluating `transform` as the new failure value if this instance represents a failure.
  public func mapError<NewFailure: Error>(
    _ transform: (Failure) -> NewFailure
  ) -> HookAsyncPhase<Success, NewFailure> {
    flatMapError { .failure(transform($0)) }
  }
  
  /// Returns a new result, mapping any success value using the given transformation and unwrapping the produced phase.
  /// - Parameter transform: A closure that takes the success value of the instance.
  /// - Returns: An `AsyncPhase` instance, either from the closure or the previous `.success`.
  public func flatMap<NewSuccess>(
    _ transform: (Success) -> HookAsyncPhase<NewSuccess, Failure>
  ) -> HookAsyncPhase<NewSuccess, Failure> {
    switch self {
      case .pending:
        return .pending
        
      case .running:
        return .running
        
      case .success(let value):
        return transform(value)
        
      case .failure(let error):
        return .failure(error)
    }
  }
  
  /// Returns a new result, mapping any failure value using the given transformation and unwrapping the produced phase.
  /// - Parameter transform: A closure that takes the failure value of the instance.
  /// - Returns: An `AsyncPhase` instance, either from the closure or the previous `.failure`.
  public func flatMapError<NewFailure: Error>(
    _ transform: (Failure) -> HookAsyncPhase<Success, NewFailure>)
  -> HookAsyncPhase<Success, NewFailure> {
    switch self {
      case .pending:
        return .pending
        
      case .running:
        return .running
        
      case .success(let value):
        return .success(value)
        
      case .failure(let error):
        return transform(error)
    }
  }
}

extension HookAsyncPhase {
  /// The status using in HookUpdateStrategy to order handle response phase.
  public enum StatusPhase: Hashable, Equatable {
    /// Represents a pending phase.
    case pending
    /// Represents a running phase.
    case running
    /// Represents a success phase.
    case success
    /// Represents a failure phase.
    case failure
  }
  
  /// the status of phase which we can compare to update HookUpdateStrategy.
  public var status: StatusPhase {
    switch self {
      case .pending:
        return .pending
      case .running:
        return .running
      case .success(_):
        return .success
      case .failure(_):
        return .failure
    }
  }
}

extension HookAsyncPhase: Decodable where Success: Decodable, Failure: Decodable { }

extension HookAsyncPhase: Encodable where Success: Encodable, Failure: Encodable {}

extension HookAsyncPhase: Equatable where Success: Equatable, Failure: Equatable {}

extension HookAsyncPhase: Hashable where Success: Hashable, Failure: Hashable {}

extension HookAsyncPhase: Sendable where Success: Sendable {}

extension HookAsyncPhase {
  /// Merge AysncPhase
  /// We receive Success and show to the view only If 2 phase is Success.
  /// - Parameter other: other AsyncPhase
  /// - Returns: AsyncPhase
  public func merge(_ other: Self) -> HookAsyncPhase<(Success, Success), Failure> {
    switch (self, other) {
      case (.failure(let error), _):
        return .failure(error)
      case (_, .failure(let error)):
        return .failure(error)
      case (.pending, _):
        return .pending
      case (_, .pending):
        return .pending
      case (.running, _), (_, .running):
        return .running
      case (.success(let thisData), .success(let otherData)):
        return .success((thisData, otherData))
    }
  }
}

extension TaskResult {
  /// Convert A TaskResult to AsyncPhase
  /// - Returns: AsyncPhase
  public func toAsyncPhase() -> HookAsyncPhase<Success, Error> {
    HookAsyncPhase(self)
  }
}

extension Result {
  /// Transform A Result to AyncPhase
  /// - Returns: AsyncPhase
  public func toAsyncPhase() -> HookAsyncPhase<Success, Failure> {
    HookAsyncPhase(self)
  }
}
