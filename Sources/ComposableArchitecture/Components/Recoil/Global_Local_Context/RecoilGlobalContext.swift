import Combine
import SwiftUI
import Foundation

@MainActor
public struct RecoilGlobalContext: AtomWatchableContext {
  @usableFromInline
  internal let _store: StoreContext
  @usableFromInline
  internal let _container: SubscriptionContainer.Wrapper
  
  @usableFromInline
  @ObservableListener
  var observable
  
  internal init(
    store: StoreContext,
    container: SubscriptionContainer.Wrapper,
    notifyUpdate: @escaping () -> Void
  ) {
    _store = store
    _container = container
    observable.sink(notifyUpdate)
  }
  
  /// A callback to perform when any of atoms watched by this context is updated.
  public var objectWillChange: AnyPublisher<Void, Never> {
    observable.objectWillChange
  }
  
  /// Accesses the value associated with the given atom without watching to it.
  ///
  /// This method returns a value for the given atom. Even if you access to a value with this method,
  /// it doesn't initiating watch the atom, so if none of other atoms or views is watching as well,
  /// the value will not be cached.
  ///
  /// ```swift
  /// let context = ...
  /// print(context.read(TextAtom()))  // Prints the current value associated with `TextAtom`.
  /// ```
  ///
  /// - Parameter atom: An atom that associates the value.
  ///
  /// - Returns: The value associated with the given atom.
  @inlinable
  public func read<Node: Atom>(_ atom: Node) -> Node.Loader.Value {
    _store.read(atom)
  }
  
  /// Sets the new value for the given writable atom.
  ///
  /// This method only accepts writable atoms such as types conforming to ``StateAtom``,
  /// and assign a new value for the atom.
  /// When you assign a new value, it notifies update immediately to downstream atoms or views.
  ///
  /// - SeeAlso: ``AtomViewContext/subscript``
  ///
  /// ```swift
  /// let context = ...
  /// print(context.watch(TextAtom())) // Prints "Text"
  /// context.set("New text", for: TextAtom())
  /// print(context.read(TextAtom()))  // Prints "New text"
  /// ```
  ///
  /// - Parameters
  ///   - value: A value to be set.
  ///   - atom: An atom that associates the value.
  @inlinable
  public func set<Node: StateAtom>(_ value: Node.Loader.Value, for atom: Node) {
    _store.set(value, for: atom)
  }
  
  /// Modifies the cached value of the given writable atom.
  ///
  /// This method only accepts writable atoms such as types conforming to ``StateAtom``,
  /// and assign a new value for the atom.
  /// When you modify value, it notifies update to downstream atoms or views after all
  /// the modification completed.
  ///
  /// ```swift
  /// let context = ...
  /// print(context.watch(TextAtom())) // Prints "Text"
  /// context.modify(TextAtom()) { text in
  ///     text.append(" modified")
  /// }
  /// print(context.read(TextAtom()))  // Prints "Text modified"
  /// ```
  ///
  /// - Parameters
  ///   - atom: An atom that associates the value.
  ///   - body: A value modification body.
  @inlinable
  public func modify<Node: StateAtom>(_ atom: Node, body: (inout Node.Loader.Value) -> Void) {
    _store.modify(atom, body: body)
  }
  
  /// Refreshes and then return the value associated with the given refreshable atom.
  ///
  /// This method only accepts refreshable atoms such as types conforming to:
  /// ``TaskAtom``, ``ThrowingTaskAtom``, ``AsyncSequenceAtom``, ``PublisherAtom``.
  /// It refreshes the value for the given atom and then return, so the caller can await until
  /// the value completes the update.
  /// Note that it can be used only in a context that supports concurrency.
  ///
  /// ```swift
  /// let context = ...
  /// let image = await context.refresh(AsyncImageDataAtom()).value
  /// print(image) // Prints the data obtained through network.
  /// ```
  ///
  /// - Parameter atom: An atom that associates the value.
  ///
  /// - Returns: The value which completed refreshing associated with the given atom.
  @discardableResult
  @inlinable
  public func refresh<Node: Atom>(_ atom: Node) async -> Node.Loader.Value where Node.Loader: RefreshableAtomLoader {
    await _store.refresh(atom)
  }
  
  /// Resets the value associated with the given atom, and then notify.
  ///
  /// This method resets a value for the given atom, and then notify update to the downstream
  /// atoms and views. Thereafter, if any of other atoms or views is watching the atom, a newly
  /// generated value will be produced.
  ///
  /// ```swift
  /// let context = ...
  /// print(context.watch(TextAtom())) // Prints "Text"
  /// context[TextAtom()] = "New text"
  /// print(context.read(TextAtom())) // Prints "New text"
  /// context.reset(TextAtom())
  /// print(context.read(TextAtom())) // Prints "Text"
  /// ```
  ///
  /// - Parameter atom: An atom that associates the value.
  @inlinable
  public func reset(_ atom: some Atom) {
    _store.reset(atom)
  }
  
  /// Accesses the value associated with the given atom for reading and initialing watch to
  /// receive its updates.
  ///
  /// This method returns a value for the given atom and initiate watching the atom so that
  /// the current context to get updated when the atom notifies updates.
  /// The value associated with the atom is cached until it is no longer watched to or until
  /// it is updated.
  ///
  /// ```swift
  /// let context = ...
  /// let text = context.watch(TextAtom())
  /// print(text) // Prints the current value associated with `TextAtom`.
  /// ```
  ///
  /// - Parameter atom: An atom that associates the value.
  ///
  /// - Returns: The value associated with the given atom.
  @discardableResult
  @inlinable
  public func watch<Node: Atom>(_ atom: Node) -> Node.Loader.Value {
    _store.watch(
      atom,
      container: _container,
      requiresObjectUpdate: true,
      notifyUpdate: observable.send
    )
  }
  
  /// For debugging, takes a snapshot that captures specific set of values of atoms.
  ///
  /// This method captures all atom values and dependencies currently in use somewhere in
  /// the descendants of `AtomRoot` and returns a `Snapshot` that allows you to analyze
  /// or rollback to a specific state.
  ///
  /// - Returns: A snapshot that captures specific set of values of atoms.
  @discardableResult
  @inlinable
  public func snapshot() -> Snapshot {
    _store.snapshot()
  }
  
  /// For debugging, restore atom values and the dependency graph captured at a point in time in the given snapshot.
  ///
  /// Atoms and their dependencies that are no longer subscribed to from anywhere are then released.
  ///
  /// - Parameter snapshot: A snapshot that captures specific set of values of atoms.
  @inlinable
  public func restore(_ snapshot: Snapshot) {
    _store.restore(snapshot)
  }
}

// MARK: PropertyWrapper

@MainActor
@propertyWrapper
public struct RecoilGlobalViewContext {
  
  @Dependency(\.recoilStoreContext)
  private var _store
  
  private var state = State()
  
  private var overrides = [OverrideKey: any AtomOverrideProtocol]()
  
  private var observers = [Observer]()
  
  private let location: SourceLocation
  
  init(location: SourceLocation) {
    self.location = location
  }
  
  public init(fileID: String = #fileID, line: UInt = #line) {
    location = SourceLocation(fileID: fileID, line: line)
  }
  
  public var wrappedValue: RecoilGlobalContext {
    RecoilGlobalContext(
      store: .scoped(
        key: ScopeKey(token: state.token),
        store: State.store,
        observers: observers,
        overrides: overrides
      ),
      container: state.container.wrapper(location: location)
    ) {
        print("💚 Re-Render in: \(location)")
      }
  }
  
  final class State {
    let container = SubscriptionContainer()
    let token = ScopeKey.Token()
    static let store = AtomStore()
  }
}

@propertyWrapper
@MainActor
struct RecoilGlobalWatch<Node: Atom> {
  
  private let atom: Node
  
  private var _context: RecoilGlobalViewContext
  
  private var context: RecoilGlobalContext
  
  public init(_ atom: Node, fileID: String = #fileID, line: UInt = #line) {
    self.atom = atom
    self._context = RecoilGlobalViewContext(fileID: fileID, line: line)
    context = _context.wrappedValue
  }
  
  public var wrappedValue: Node.Loader.Value {
    context.watch(atom)
  }
}


@propertyWrapper
@MainActor
struct RecoilGlobalWatchState<Node: StateAtom> {
  
  private let atom: Node
  
  private var _context: RecoilGlobalViewContext
  
  private var context: RecoilGlobalContext
  
  public init(_ atom: Node, fileID: String = #fileID, line: UInt = #line) {
    self.atom = atom
    self._context = RecoilGlobalViewContext(fileID: fileID, line: line)
    context = _context.wrappedValue
  }
  
  public var wrappedValue: Node.Loader.Value {
    get { context.watch(atom) }
    nonmutating set { context.set(newValue, for: atom) }
  }
  
  public var projectedValue: Binding<Node.Loader.Value> {
    context.state(atom)
  }
}

@propertyWrapper
@MainActor
struct RecoilGlobalWatchStateObject<Node: ObservableObjectAtom> {
  
  @dynamicMemberLookup
  public struct Wrapper {
    private let object: Node.Loader.Value
    
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
  
  private var _context: RecoilGlobalViewContext
  
  private var context: RecoilGlobalContext
  
  public init(_ atom: Node, fileID: String = #fileID, line: UInt = #line) {
    self.atom = atom
    self._context = RecoilGlobalViewContext(fileID: fileID, line: line)
    context = _context.wrappedValue
  }
  
  public var wrappedValue: Node.Loader.Value {
    context.watch(atom)
  }
  
  public var projectedValue: Wrapper {
    Wrapper(wrappedValue)
  }
}


/// A view that wrapper around the `HookScope` to use hooks inside with Recoil.
/// The view that is completion from `init` will be encluded with `Context` and e able to use hooks.
///
/// ```swift
///  struct Content: View {
///   var body: some View {
///     RecoilRoot { context in
///      // TODO
///     }
///   }
///  }
///
/// ```
@MainActor
public struct _RecoilGlobalScope<Content: View>: View {
  
  private let content: (RecoilGlobalContext) -> Content
  
  public typealias Context = RecoilGlobalContext
  
  private var _context: RecoilGlobalViewContext
  
  private var context: RecoilGlobalContext
  
  public init(
    fileID: String = #fileID,
    line: UInt = #line,
    @ViewBuilder _ content: @escaping (Context) -> Content
  ) {
    self.content = content
    let location = SourceLocation(fileID: fileID, line: line)
    _context = RecoilGlobalViewContext(location: location)
    context = _context.wrappedValue
  }
  
  public var body: some View {
    HookScope {
      content(context)
    }
  }
}

@MainActor
public protocol _RecoilGlobalView: View {
  // The type of view representing the body of this view that can use recoil.
  associatedtype RecoilBody: View
  
  typealias Context = RecoilGlobalContext

  var _context: RecoilGlobalViewContext { get set }

  @ViewBuilder
  func build(context: Context) -> RecoilBody
  
}

extension _RecoilGlobalView {
  public var body: some View {
    HookScope {
      build(context: context)
    }
  }
  
  var context: RecoilGlobalContext {
    _context.wrappedValue
  }
}


/// A view that wrapper around the `RecoilGlobalScope` to use hooks inside.
/// The view that is returned from `recoilBody` will be encluded with `RecoilGlobalScope` and `HookScope` and be able to use hooks.
///
/// ```swift
/// private struct _RecoilGlobalView: RecoilGlobalView {
///
///  func recoilBody(context: RecoilGlobalContext) -> some View {
///
///  }
///}
///```
@MainActor
public protocol RecoilGlobalView: View {
  // The type of view representing the body of this view that can use recoil.
  associatedtype RecoilBody: View
  
  typealias Context = RecoilGlobalContext
  
  /// The content and behavior of the hook scoped view.
  @ViewBuilder
  func recoilBody(context: Context) -> RecoilBody
}

extension RecoilGlobalView {
  /// The content and behavior of the view.
  public var body: some View {
    RecoilGlobalScope { context in
      recoilBody(context: context)
    }
  }
}

/// A view that wrapper around "RecoilLocalScope"  to use hooks inside.
/// ```swift
///RecoilGlobalScope { globalViewContext in
///
///}
/// ```
public struct RecoilGlobalScope<Content: View>: View {
  
  public typealias Context = RecoilGlobalContext
  
  private let content: (Context) -> Content
  
  /// Creates a `HookScope` that hosts the state of hooks.
  /// - Parameter content: A content view that uses the hooks.
  public init(@ViewBuilder _ content: @escaping (Context) -> Content) {
    self.content = content
  }
  
  /// The content and behavior of the hook scoped view.
  public var body: some View {
    if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
      RecoilScopeBody(content)
    }
    else {
      RecoilScopeCompatBody(content)
    }
  }
}

@MainActor
private class RecoilGlobalObservable: ObservableObject {
  
  var _context: RecoilGlobalViewContext
  
  var context: RecoilGlobalContext
  
  var cancellables: SetCancellables = []
  
  init(
    fileID: String = #fileID,
    line: UInt = #line
  ) {
    let location = SourceLocation(fileID: fileID, line: line)
    _context = RecoilGlobalViewContext(location: location)
    context = _context.wrappedValue
    context.objectWillChange.sink { [weak self] _ in
      self?.objectWillChange.send()
    }
    .store(in: &cancellables)
  }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct RecoilScopeBody<Content: View>: View {
  @StateObject
  private var hookObservable = RecoilGlobalObservable()

  
  private let content: (RecoilGlobalContext) -> Content
  
  init(@ViewBuilder _ content: @escaping (RecoilGlobalContext) -> Content) {
    self.content = content
  }
  
  var body: some View {
    HookScope {
      content(hookObservable.context)
    }
  }
}

@available(iOS, deprecated: 14.0)
@available(macOS, deprecated: 11.0)
@available(tvOS, deprecated: 14.0)
@available(watchOS, deprecated: 7.0)
@MainActor
private struct RecoilScopeCompatBody<Content: View>: View {
  struct Body: View {
    @ObservedObject
    private var recoilGlobalObservable: RecoilGlobalObservable
    
    @Environment(\.self)
    private var environment
    
    private let content: (RecoilGlobalContext) -> Content
    
    init(
      recoilGlobalObservable: RecoilGlobalObservable,
         @ViewBuilder _ content: @escaping (RecoilGlobalContext) -> Content
    ) {
      self.recoilGlobalObservable = recoilGlobalObservable
      self.content = content
    }
    
    var body: some View {
      HookScope {
        content(recoilGlobalObservable.context)
      }
    }
  }
  
  @State
  private var recoilGlobalObservable = RecoilGlobalObservable()
  private let content: (RecoilGlobalContext) -> Content
  
  init(@ViewBuilder _ content: @escaping (RecoilGlobalContext) -> Content) {
    self.content = content
  }
  
  var body: Body {
    Body(recoilGlobalObservable: recoilGlobalObservable, content)
  }
}
