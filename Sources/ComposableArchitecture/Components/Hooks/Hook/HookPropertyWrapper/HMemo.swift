import Foundation

@propertyWrapper
public struct HMemo<Node> {
  
  private let initialNode: () -> Node
  
  private let updateStrategy: HookUpdateStrategy
  
  public init(
    wrappedValue: Node,
    _ updateStrategy: HookUpdateStrategy = .once
  ) {
    initialNode = { wrappedValue }
    self.updateStrategy = updateStrategy
  }
  
  public init(
    wrappedValue: @escaping () -> Node,
    _ updateStrategy: HookUpdateStrategy = .once
  ) {
    initialNode = wrappedValue
    self.updateStrategy = updateStrategy
  }
  
  public var wrappedValue: Node {
    useMemo(updateStrategy, initialNode)
  }
  
  public var projectedValue: Self {
    self
  }
}
