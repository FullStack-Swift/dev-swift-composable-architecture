/// A value that represents either a success or a failure. This type differs from Swift's `Result`
/// type in that it uses only one generic for the success case, leaving the failure case as an
/// untyped `Error`.
///
/// This type is needed because Swift's concurrency tools can only express untyped errors, such as
/// `async` functions and `AsyncSequence`, and so their output can realistically only be bridged to
/// `Result<_, Error>`. However, `Result<_, Error>` is never `Equatable` since `Error` is not
/// `Equatable`, and equatability is very important for testing in the Composable Architecture. By
/// defining our own type we get the ability to recover equatability in most situations.
///
/// If someday Swift gets typed `throws`, then we can eliminate this type and rely solely on
/// `Result`.
///
/// You typically use this type as the payload of an action which receives a response from an
/// effect:
///
/// ```swift
/// enum Action: Equatable {
///   case factButtonTapped
///   case factResponse(TaskResult<String>)
/// }
/// ```
///
/// Then you can model your dependency as using simple `async` and `throws` functionality:
///
/// ```swift
/// struct NumberFactClient {
///   var fetch: (Int) async throws -> String
/// }
/// ```
///
/// And finally you can use ``Effect/run(priority:operation:catch:fileID:line:)`` to construct an
/// effect in the reducer that invokes the `numberFact` endpoint and wraps its response in a
/// ``TaskResult`` by using its catching initializer, ``TaskResult/init(catching:)``:
///
/// ```swift
/// case .factButtonTapped:
///   return .run { send in
///     await send(
///       .factResponse(
///         TaskResult { try await self.numberFact.fetch(state.number) }
///       )
///     )
///   }
///
/// case let .factResponse(.success(fact)):
///   // do something with fact
///
/// case .factResponse(.failure):
///   // handle error
///
/// // ...
/// }
/// ```
///
/// ## Equality
///
/// The biggest downside to using an untyped `Error` in a result type is that the result will not
/// be equatable even if the success type is. This negatively affects your ability to test features
/// that use ``TaskResult`` in their actions with the ``TestStore``.
///
/// ``TaskResult`` does extra work to try to maintain equatability when possible. If the underlying
/// type masked by the `Error` is `Equatable`, then it will use that `Equatable` conformance
/// on two failures. Luckily, most errors thrown by Apple's frameworks are already equatable, and
/// because errors are typically simple value types, it is usually possible to have the compiler
/// synthesize a conformance for you.
///
/// If you are testing the unhappy path of a feature that feeds a ``TaskResult`` back into the
/// system, be sure to conform the error to equatable, or the test will fail:
///
/// ```swift
/// // Set up a failing dependency
/// struct RefreshFailure: Error {}
/// store.dependencies.apiClient.fetchFeed = { throw RefreshFailure() }
///
/// // Simulate pull-to-refresh
/// store.send(.refresh) { $0.isLoading = true }
///
/// // Assert against failure
/// await store.receive(.refreshResponse(.failure(RefreshFailure())) { // 🛑
///   $0.errorLabelText = "An error occurred."
///   $0.isLoading = false
/// }
/// // 🛑 'RefreshFailure' is not equatable
/// ```
///
/// To get a passing test, explicitly conform your custom error to the `Equatable` protocol:
///
/// ```swift
/// // Set up a failing dependency
/// struct RefreshFailure: Error, Equatable {} // 👈
/// store.dependencies.apiClient.fetchFeed = { throw RefreshFailure() }
///
/// // Simulate pull-to-refresh
/// store.send(.refresh) { $0.isLoading = true }
///
/// // Assert against failure
/// await store.receive(.refreshResponse(.failure(RefreshFailure())) { // ✅
///   $0.errorLabelText = "An error occurred."
///   $0.isLoading = false
/// }
/// ```
public enum TaskResult<Success: Sendable>: Sendable {
  /// A success, storing a `Success` value.
  case success(Success)
  
  /// A failure, storing an error.
  case failure(Error)
  
  /// Creates a new task result by evaluating an async throwing closure, capturing the returned
  /// value as a success, or any thrown error as a failure.
  ///
  /// This initializer is most often used in an async effect being returned from a reducer. See the
  /// documentation for ``TaskResult`` for a concrete example.
  ///
  /// - Parameter body: An async, throwing closure.
  @_transparent
  public init(catching body: @Sendable () async throws -> Success) async {
    do {
      self = .success(try await body())
    } catch {
      self = .failure(error)
    }
  }
  
  /// Transforms a `Result` into a `TaskResult`, erasing its `Failure` to `Error`.
  ///
  /// - Parameter result: A result.
  @inlinable
  public init<Failure>(_ result: Result<Success, Failure>) {
    switch result {
      case let .success(value):
        self = .success(value)
      case let .failure(error):
        self = .failure(error)
    }
  }
  
  /// Returns the success value as a throwing property.
  @inlinable
  public var value: Success {
    get throws {
      switch self {
        case let .success(value):
          return value
        case let .failure(error):
          throw error
      }
    }
  }
  
  public var result: Result<Success, Error> {
    switch self {
      case .success(let success):
        return .success(success)
      case .failure(let error):
        return .failure(error)
    }
  }
  
  /// Returns a new task result, mapping any success value using the given transformation.
  ///
  /// Like `map` on `Result`, `Optional`, and many other types.
  ///
  /// - Parameter transform: A closure that takes the success value of this instance.
  /// - Returns: A `TaskResult` instance with the result of evaluating `transform` as the new
  ///   success value if this instance represents a success.
  @inlinable
  public func map<NewSuccess>(_ transform: (Success) -> NewSuccess) -> TaskResult<NewSuccess> {
    switch self {
      case let .success(value):
        return .success(transform(value))
      case let .failure(error):
        return .failure(error)
    }
  }
  
  /// Returns a new task result, mapping any success value using the given transformation and
  /// unwrapping the produced result.
  ///
  /// Like `flatMap` on `Result`, `Optional`, and many other types.
  ///
  /// - Parameter transform: A closure that takes the success value of the instance.
  /// - Returns: A `TaskResult` instance, either from the closure or the previous `.failure`.
  @inlinable
  public func flatMap<NewSuccess>(
    _ transform: (Success) -> TaskResult<NewSuccess>
  ) -> TaskResult<NewSuccess> {
    switch self {
      case let .success(value):
        return transform(value)
      case let .failure(error):
        return .failure(error)
    }
  }
}

extension Result where Success: Sendable, Failure == Error {
  /// Transforms a `TaskResult` into a `Result`.
  ///
  /// - Parameter result: A task result.
  @inlinable
  public init(_ result: TaskResult<Success>) {
    switch result {
      case let .success(value):
        self = .success(value)
      case let .failure(error):
        self = .failure(error)
    }
  }
}

extension Result {
  func toTaskResult() -> TaskResult<Success> {
    TaskResult(self)
  }
}

extension TaskResult {
  func toResult() -> Result<Success, Error> {
    result
  }
}
