import Foundation

@propertyWrapper
public struct HUseAsync<Output> {
  
  private var updateStrategy: HookUpdateStrategy?
  
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

@propertyWrapper
public struct HUseThrowingAsync<Output> {
  
  private var updateStrategy: HookUpdateStrategy?
  
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

@propertyWrapper
public struct HUsePublisher<P: Publisher> {
  
  private var updateStrategy: HookUpdateStrategy = .once
  
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
