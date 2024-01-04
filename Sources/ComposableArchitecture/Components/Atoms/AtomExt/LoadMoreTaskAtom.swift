// MARK: Make TaskAtom
public struct LoadMoreTaskAtom<Node>: TaskAtom {
  
  public typealias Value = Node
  
  public typealias UpdatedContext = AtomUpdatedContext<Void>
  
  public var id: String
  
  public var initialState: (Self.Context) async -> Node
  
  @SRefObject
  internal var _location: ((Value, Value, UpdatedContext) -> Void)? = nil
  
  public init(id: String,_ initialState: @escaping (Self.Context) async -> Node) {
    self.id = id
    self.initialState = initialState
  }
  
  public init(id: String, _ initialState: @escaping() async -> Node) {
    self.init(id: id) { _ in
      await initialState()
    }
  }
  
  public init(id: String, _ initialState: Node) {
    self.init(id: id) { _ in
      initialState
    }
  }
  
  @MainActor
  public func value(context: Self.Context) async -> Value {
    await initialState(context)
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
  
  public var key: String {
    self.id
  }
}
