/// An atom type that provides a read-write state value.
///
/// This atom provides a mutable state value that can be accessed from anywhere, and it notifies changes
/// to downstream atoms and views.
///
/// ## Output Value
///
/// Self.Value
///
/// ## Example
///
/// ```swift
/// struct CounterAtom: StateAtom, Hashable {
///     func defaultValue(context: Context) -> Int {
///         0
///     }
/// }
///
/// struct CounterView: View {
///     @WatchState(CounterAtom())
///     var count
///
///     var body: some View {
///         Stepper("Count: \(count)", value: $count)
///     }
/// }
/// ```
///
public protocol StateAtom: Atom {
  /// The type of state value that this atom produces.
  associatedtype Value
  
  /// Creates a default value of the state that to be provided via this atom.
  ///
  /// The value returned from this method will be the default state value. When this atom is reset,
  /// the state will revert to this value.
  ///
  /// - Parameter context: A context structure that to read, watch, and otherwise
  ///                      interacting with other atoms.
  ///
  /// - Returns: A default value of state.
  @MainActor
  func defaultValue(context: Context) -> Value
}

public extension StateAtom {
  @MainActor
  var _loader: StateAtomLoader<Self> {
    StateAtomLoader(atom: self)
  }
}

public struct MStateAtom<Node>: StateAtom {

  public typealias Value = Node
  
  public typealias UpdatedContext = AtomUpdatedContext<Void>

  public var id: String = ""
  
  public var initialState: (Self.Context) -> Node
  
  public var _onUpdated: ((Value, Value, MValueAtom.UpdatedContext) -> Void)?

  public init(id: String,_ initialState: @escaping (Self.Context) -> Node) {
    self.id = id
    self.initialState = initialState
  }

  public init(id: String, _ initialState: Node) {
    self.init(id: id) { _ in
      initialState
    }
  }

  public func defaultValue(context: Self.Context) -> Node {
    initialState(context)
  }
  
  public func updated(newValue: Value, oldValue: Value, context: UpdatedContext) {
    _onUpdated?(newValue, oldValue, context)
  }
  
  @discardableResult
  public mutating func onUpdated(_ onUpdate: @escaping (Value, Value, Self.UpdatedContext) -> Void) -> Self {
    _onUpdated = onUpdate
    return self
  }

  public var key: String {
    self.id
  }
}
