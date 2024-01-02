import Foundation

@propertyWrapper
@MainActor public struct RecoilRead<Node: Atom> {
  
  let ref: RecoilHookRef<Node>
  
  private let updateStrategy: HookUpdateStrategy
  
  public init(
    node: Node,
    updateStrategy: HookUpdateStrategy = .once,
    fileID: String = #fileID,
    line: UInt = #line
  ) {
    self.updateStrategy = updateStrategy
    ref = RecoilHookRef(location: SourceLocation(fileID: fileID, line: line), initialNode: node)
  }
  
  public var wrappedValue: Node.Loader.Value {
    useRecoilReadValue(updateStrategy: updateStrategy, ref.node)
  }
  
  public var value: Node.Loader.Value {
    wrappedValue
  }
  
  public var projectedValue: Self {
    self
  }
}
