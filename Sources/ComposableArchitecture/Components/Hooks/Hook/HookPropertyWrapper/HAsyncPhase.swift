import Foundation

// MARK: Base @propertyWrapper for AsyncPhase and TaskAsyncPhase

public protocol HAsyncPhase {
  
  associatedtype Output
  
  associatedtype Failure: Error
  
  var updateStrategy: HookUpdateStrategy? { get set }
  
  var value: AsyncPhase<Output, Failure> { get }
  
  var projectedValue: Self { get }
  
  var taskAsyncPhase: TaskAsyncPhase<Output> { get }
}

extension HAsyncPhase {
  
  public var projectedValue: Self {
    self
  }
  
  public var asyncPhase: AsyncPhase<Output, Failure> {
    value
  }
  
  public var taskAsyncPhase: TaskAsyncPhase<Output> {
    value.toTaskAsyncPhase()
  }
}

// MARK: HUseAsync
@propertyWrapper
public struct HUseAsync<Output>: HAsyncPhase {
  
  public var updateStrategy: HookUpdateStrategy?
  
  private var operation: AsyncReturn<Output>
  
  public init(
    wrappedValue: @escaping AsyncReturn<Output>,
    _ updateStrategy: HookUpdateStrategy? = .once
  ) {
    self.operation = wrappedValue
    self.updateStrategy = updateStrategy
  }
  
  public var wrappedValue: AsyncReturn<Output> {
    operation
  }
  
  public var projectedValue: Self {
    self
  }
  
  public var value: AsyncPhase<Output, Never> {
    useAsync(updateStrategy, operation)
  }
}

// MARK: HUseThrowingAsync
@propertyWrapper
public struct HUseThrowingAsync<Output>: HAsyncPhase {
  
  public var updateStrategy: HookUpdateStrategy?
  
  private var operation: ThrowingAsyncReturn<Output>
  
  public init(
    wrappedValue: @escaping ThrowingAsyncReturn<Output>,
    _ updateStrategy: HookUpdateStrategy? = .once
  ) {
    self.operation = wrappedValue
    self.updateStrategy = updateStrategy
  }
  
  public var wrappedValue: ThrowingAsyncReturn<Output> {
    operation
  }
  
  public var projectedValue: Self {
    self
  }
  
  public var value: AsyncPhase<Output, Error> {
    useAsync(updateStrategy, operation)
  }
}

import Combine

// MARK: HUsePublisher
@propertyWrapper
public struct HUsePublisher<P: Publisher>: HAsyncPhase {
  
  public var updateStrategy: HookUpdateStrategy? = .once
  
  private let operation: () -> P
  
  public init(
    wrappedValue: @escaping () -> P,
    _ updateStrategy: HookUpdateStrategy = .once
  ) {
    self.operation = wrappedValue
    self.updateStrategy = updateStrategy
  }
  
  public var wrappedValue: () -> P {
    operation
  }
  
  public var projectedValue: Self {
    self
  }
  
  public var value: AsyncPhase<P.Output, P.Failure> {
    usePublisher(updateStrategy, operation)
  }
}

// MARK: HUseAsyncSequence
@propertyWrapper
public struct HUseAsyncSequence<Output>: HAsyncPhase {
  public var updateStrategy: HookUpdateStrategy? = .once
  
  private let operation: AsyncStream<Output>
  
  public init(
    wrappedValue: AsyncStream<Output>,
    _ updateStrategy: HookUpdateStrategy = .once
  ) {
    self.operation = wrappedValue
    self.updateStrategy = updateStrategy
  }
  
  public var wrappedValue: AsyncStream<Output> {
    operation
  }
  
  public var projectedValue: Self {
    self
  }
  
  public var value: AsyncPhase<Output, Never> {
    useAsyncSequence(updateStrategy, operation)
  }
}

// MARK: HUseAsyncThrowingSequence
@propertyWrapper
public struct HUseAsyncThrowingSequence<Output>: HAsyncPhase {
  public var updateStrategy: HookUpdateStrategy? = .once
  
  private let operation: AsyncThrowingStream<Output, any Error>
  
  public init(
    wrappedValue: AsyncThrowingStream<Output, any Error>,
    _ updateStrategy: HookUpdateStrategy = .once
  ) {
    self.operation = wrappedValue
    self.updateStrategy = updateStrategy
  }
  
  public var wrappedValue: AsyncThrowingStream<Output, any Error> {
    operation
  }
  
  public var projectedValue: Self {
    self
  }
  
  public var value: AsyncPhase<Output, any Error> {
    useAsyncThrowingSequence(updateStrategy, operation)
  }
}
