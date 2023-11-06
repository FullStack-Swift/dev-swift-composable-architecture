import Foundation

@propertyWrapper
public struct HAsyncPhase<Output> {
  
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
  
  public var projectedValue: AsyncPhase<Output, Never> {
    useAsync(updateStrategy, operation)
  }
}
