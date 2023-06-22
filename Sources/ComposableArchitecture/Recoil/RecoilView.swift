import SwiftUI

/// https://recoiljs.org/

public struct RecoilRoot<Content: View>: View {

  private let content: (AtomViewContext) -> Content

  @ViewContext
  private var context

  public init(@ViewBuilder _ content: @escaping (AtomViewContext) -> Content) {
    self.content = content
  }

  public var body: some View {
    HookScope {
      content(context)
    }
  }
}

public struct RecoilScope<Content: View>: View {

  private let content: (AtomViewContext) -> Content

  @ViewContext
  var context

  public init(@ViewBuilder _ content: @escaping (AtomViewContext) -> Content) {
    self.content = content
  }

  public var body: some View {
    HookScope {
      content(context)
    }
  }
}

@propertyWrapper
@MainActor struct _ViewContext {

  @Dependency(\.storeContext)
  private var _store

  private let location: SourceLocation

  public init(fileID: String = #fileID, line: UInt = #line) {
    location = SourceLocation(fileID: fileID, line: line)
  }

  public var wrappedValue: AtomRecoilContext {
    AtomRecoilContext(fileID: location.fileID, line: location.line)
  }
}


@propertyWrapper
struct _Watch<Node: Atom> {
  private let atom: Node

  @_ViewContext
  private var context

  /// Creates a watch with the atom that to be watched.
  public init(_ atom: Node, fileID: String = #fileID, line: UInt = #line) {
    self.atom = atom
    self._context = _ViewContext(fileID: fileID, line: line)
  }

  /// The underlying value associated with the given atom.
  ///
  /// This property provides primary access to the value's data. However, you don't
  /// access ``wrappedValue`` directly. Instead, you use the property variable created
  /// with the `@Watch` attribute.
  /// Accessing to this property starts watching to the atom.
  public var wrappedValue: Node.Loader.Value {
    context.watch(atom)
  }
}


@propertyWrapper
struct _WatchState<Node: StateAtom> {
  private let atom: Node

  @_ViewContext
  private var context

  /// Creates a watch with the atom that to be watched.
  public init(_ atom: Node, fileID: String = #fileID, line: UInt = #line) {
    self.atom = atom
    self._context = _ViewContext(fileID: fileID, line: line)
  }

  /// The underlying value associated with the given atom.
  ///
  /// This property provides primary access to the value's data. However, you don't
  /// access ``wrappedValue`` directly. Instead, you use the property variable created
  /// with the `@WatchState` attribute.
  /// Accessing to the getter of this property starts watching to the atom, but doesn't
  /// by setting a new value.
  public var wrappedValue: Node.Loader.Value {
    get { context.watch(atom) }
    nonmutating set { context.set(newValue, for: atom) }
  }

  /// A binding to the atom value.
  ///
  /// Use the projected value to pass a binding value down a view hierarchy.
  /// To get the ``projectedValue``, prefix the property variable with `$`.
  /// Accessing to this property itself doesn't starts watching to the atom, but does when
  /// the view accesses to the getter of the binding.
  public var projectedValue: Binding<Node.Loader.Value> {
    context.state(atom)
  }
}


@propertyWrapper
struct _WatchStateObject<Node: ObservableObjectAtom> {
  /// A wrapper of the underlying observable object that can create bindings to
  /// its properties using dynamic member lookup.
  @dynamicMemberLookup
  public struct Wrapper {
    private let object: Node.Loader.Value

    /// Returns a binding to the resulting value of the given key path.
    ///
    /// - Parameter keyPath: A key path to a specific resulting value.
    ///
    /// - Returns: A new binding.
    public subscript<T>(dynamicMember keyPath: ReferenceWritableKeyPath<Node.Loader.Value, T>) -> Binding<T> {
      Binding(
        get: { object[keyPath: keyPath] },
        set: { object[keyPath: keyPath] = $0 }
      )
    }

    fileprivate init(_ object: Node.Loader.Value) {
      self.object = object
    }
  }

  private let atom: Node

  @_ViewContext
  private var context

  /// Creates a watch with the atom that to be watched.
  public init(_ atom: Node, fileID: String = #fileID, line: UInt = #line) {
    self.atom = atom
    self._context = _ViewContext(fileID: fileID, line: line)
  }

  /// The underlying observable object associated with the given atom.
  ///
  /// This property provides primary access to the value's data. However, you don't
  /// access ``wrappedValue`` directly. Instead, you use the property variable created
  /// with the `@WatchStateObject` attribute.
  /// Accessing to this property starts watching to the atom.
  public var wrappedValue: Node.Loader.Value {
    context.watch(atom)
  }

  /// A projection of the state object that creates bindings to its properties.
  ///
  /// Use the projected value to pass a binding value down a view hierarchy.
  /// To get the projected value, prefix the property variable with `$`.
  public var projectedValue: Wrapper {
    Wrapper(wrappedValue)
  }
}
