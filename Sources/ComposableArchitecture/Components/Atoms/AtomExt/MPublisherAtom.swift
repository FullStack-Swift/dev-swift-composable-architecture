import Combine

// MARK: Make PublisherAtom
public struct MPublisherAtom<Node: Combine.Publisher>: PublisherAtom {
  
  public typealias Value = Node
  
  public var id: String
  
  public var initialState: (Self.Context) -> Node
  
  public typealias UpdatedContext = AtomUpdatedContext<Void>
  
  @SRefObject
  internal var _location: ((Value, Value, UpdatedContext) -> Void)? = nil
  
  public init(id: String, _ initialState: @escaping (Context) -> Node) {
    self.id = id
    self.initialState = initialState
  }
  
  public init(id: String, _ initialState: Node) {
    self.init(id: id) { _ in
      initialState
    }
  }
  
  public func publisher(context: Self.Context) -> Node {
    initialState(context)
  }
  
  public func updated(newValue: Value, oldValue: Value, context: UpdatedContext) {
    if let value = _location {
      value(newValue, oldValue, context)
    }
  }
  
  @discardableResult
  public func onUpdated(_ onUpdate: @escaping (Value, Value, Self.UpdatedContext) -> Void) -> Self {
    _location = onUpdate
    return self
  }
  
  public var key: some Hashable {
    self.id
  }
}
