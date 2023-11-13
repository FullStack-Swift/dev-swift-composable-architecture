/// An atom type that provides a nonthrowing `Task` from the given asynchronous function.
///
/// This atom guarantees that the task to be identical instance and its state can be shared
/// at anywhere even when they are accessed simultaneously from multiple locations.
///
/// - SeeAlso: ``ThrowingTaskAtom``
/// - SeeAlso: ``Suspense``
///
/// ## Output Value
///
/// Task<Self.Value, Never>
///
/// ## Example
///
/// ```swift
/// struct AsyncTextAtom: TaskAtom, Hashable {
///     func value(context: Context) async -> String {
///         try? await Task.sleep(nanoseconds: 1_000_000_000)
///         return "Swift"
///     }
/// }
///
/// struct DelayedTitleView: View {
///     @Watch(AsyncTextAtom())
///     var text
///
///     var body: some View {
///         Suspense(text) { text in
///             Text(text)
///         } suspending: {
///             Text("Loading...")
///         }
///     }
/// }
/// ```
///
public protocol TaskAtom: Atom {
  /// The type of value that this atom produces.
  associatedtype Value
  
  /// Asynchronously produces a value that to be provided via this atom.
  ///
  /// This asynchronous method is converted to a `Task` internally, and if it will be
  /// cancelled by downstream atoms or views, this method will also be cancelled.
  ///
  /// - Parameter context: A context structure that to read, watch, and otherwise
  ///                      interacting with other atoms.
  ///
  /// - Returns: A nonthrowing `Task` that produces asynchronous value.
  @MainActor
  func value(context: Context) async -> Value
}

public extension TaskAtom {
  @MainActor
  var _loader: TaskAtomLoader<Self> {
    TaskAtomLoader(atom: self)
  }
}

// MARK: Make TaskAtom
public struct MTaskAtom<Node>: TaskAtom {

  public typealias Value = Node
  
  public typealias UpdatedContext = AtomUpdatedContext<Void>

  public var id: String
  
  public var initialState: (Self.Context) async -> Node
  
  @SAnyRef
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
