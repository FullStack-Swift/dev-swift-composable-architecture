import Combine

/// An atom type that instantiates an observable object.
///
/// When published properties of the observable object provided through this atom changes, it
/// notifies updates to downstream atoms and views that watches this atom.
/// In case you want to get another atom value from the context later by methods in that
/// observable object, you can pass it as ``AtomContext``.
///
/// - Note: If you watch other atoms through the context passed as parameter, the observable
///         object itself will be re-created with fresh state when the watching atom is updated.
///
/// ## Output Value
///
/// Self.ObjectType
///
/// ## Example
///
/// ```swift
/// class Contact: ObservableObject {
///     @Published var name = ""
///     @Published var age = 20
///
///     func haveBirthday() {
///         age += 1
///     }
/// }
///
/// struct ContactAtom: ObservableObjectAtom, Hashable {
///     func object(context: Context) -> Contact {
///         Contact()
///     }
/// }
///
/// struct ContactView: View {
///     @WatchStateObject(ContactAtom())
///     var contact
///
///     var body: some View {
///         VStack {
///             TextField("Enter your name", text: $contact.name)
///             Text("Age: \(contact.age)")
///             Button("Celebrate your birthday!") {
///                 contact.haveBirthday()
///             }
///         }
///     }
/// }
/// ```
///
public protocol ObservableObjectAtom: Atom {
  /// The type of observable object that this atom produces.
  associatedtype ObjectType: ObservableObject
  
  /// Creates an observed object when this atom is actually used.
  ///
  /// The observable object that returned from this method is managed internally and notifies
  /// its updates to downstream atoms and views that watches this atom.
  ///
  /// - Parameter context: A context structure that to read, watch, and otherwise
  ///                      interacting with other atoms.
  ///
  /// - Returns: An observable object that notifies its updates over time.
  @MainActor
  func object(context: Context) -> ObjectType
}

public extension ObservableObjectAtom {
  @MainActor
  var _loader: ObservableObjectAtomLoader<Self> {
    ObservableObjectAtomLoader(atom: self)
  }
}

// MARK: Make ObservableObjectAtom
public struct MObservableObjectAtom<Node: ObservableObject>: ObservableObjectAtom {

  public typealias Value = Node
  
  public typealias ObjectType = Node
  
  public typealias UpdatedContext = AtomUpdatedContext<Void>

  public var id: String
  
  public var initialState: (Self.Context) -> Node
  
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

  public func object(context: Self.Context) -> Node {
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

  public var key: String {
    self.id
  }
}
