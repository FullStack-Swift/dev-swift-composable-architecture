import Combine
import SwiftUI
import Foundation

@propertyWrapper
@MainActor
public struct ScopeRecoilViewContext {

  private let location: SourceLocation

  public init(fileID: String = #fileID, line: UInt = #line) {
    location = SourceLocation(fileID: fileID, line: line)
  }

  public var wrappedValue: ScopeAtomRecoilContext {
    ScopeAtomRecoilContext(fileID: location.fileID, line: location.line)
  }
}


@propertyWrapper
struct ScopeRecoilWatch<Node: Atom> {
  private let atom: Node

  @ScopeRecoilViewContext
  private var context

  /// Creates a watch with the atom that to be watched.
  public init(_ atom: Node, fileID: String = #fileID, line: UInt = #line) {
    self.atom = atom
    self._context = ScopeRecoilViewContext(fileID: fileID, line: line)
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
struct ScopeRecoilWatchState<Node: StateAtom> {
  private let atom: Node

  @ScopeRecoilViewContext
  private var context

  /// Creates a watch with the atom that to be watched.
  public init(_ atom: Node, fileID: String = #fileID, line: UInt = #line) {
    self.atom = atom
    self._context = ScopeRecoilViewContext(fileID: fileID, line: line)
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
struct ScopeRecoilWatchStateObject<Node: ObservableObjectAtom> {
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

  @ScopeRecoilViewContext
  private var context

  /// Creates a watch with the atom that to be watched.
  public init(_ atom: Node, fileID: String = #fileID, line: UInt = #line) {
    self.atom = atom
    self._context = ScopeRecoilViewContext(fileID: fileID, line: line)
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


@MainActor
public struct ScopeAtomRecoilContext: AtomWatchableContext {
  private let state = State.shared
  private let location: SourceLocation

  public init(fileID: String = #fileID, line: UInt = #line) {
    location = SourceLocation(fileID: fileID, line: line)
  }

  public var onUpdate: (() -> Void)? {
    get { state.onUpdate }
    nonmutating set { state.onUpdate = newValue }
  }

  @discardableResult
  public func waitForUpdate(timeout interval: TimeInterval? = nil) async -> Bool {
    let updates = AsyncStream<Void> { continuation in
      let cancellable = state.notifier.sink(
        receiveCompletion: { completion in
          continuation.finish()
        },
        receiveValue: {
          continuation.yield()
        }
      )

      continuation.onTermination = { termination in
        switch termination {
          case .cancelled:
            cancellable.cancel()
          case .finished:
            break
          @unknown default:
            break
        }
      }
    }

    return await withTaskGroup(of: Bool.self) { group in
      group.addTask {
        var iterator = updates.makeAsyncIterator()
        await iterator.next()
        return true
      }

      if let interval {
        group.addTask {
          try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
          return false
        }
      }

      let didUpdate = await group.next() ?? false
      group.cancelAll()

      return didUpdate
    }
  }

  public func read<Node: Atom>(_ atom: Node) -> Node.Loader.Value {
    store.read(atom)
  }

  public func set<Node: StateAtom>(_ value: Node.Loader.Value, for atom: Node) {
    store.set(value, for: atom)
  }

  public func modify<Node: StateAtom>(_ atom: Node, body: (inout Node.Loader.Value) -> Void) {
    store.modify(atom, body: body)
  }

  @discardableResult
  public func refresh<Node: Atom>(_ atom: Node) async -> Node.Loader.Value where Node.Loader: RefreshableAtomLoader {
    await store.refresh(atom)
  }

  public func reset(_ atom: some Atom) {
    store.reset(atom)
  }

  @discardableResult
  public func watch<Node: Atom>(_ atom: Node) -> Node.Loader.Value {
    store.watch(atom, container: container, requiresObjectUpdate: true) { [weak state] in
      state?.notifyUpdate()
    }
  }

  public func unwatch(_ atom: some Atom) {
    store.unwatch(atom, container: container)
  }

  public func override<Node: Atom>(_ atom: Node, with value: @escaping (Node) -> Node.Loader.Value) {
    state.overrides[OverrideKey(atom)] = AtomOverride(value: value)
  }

  public func override<Node: Atom>(_ atomType: Node.Type, with value: @escaping (Node) -> Node.Loader.Value) {
    state.overrides[OverrideKey(atomType)] = AtomOverride(value: value)
  }
}

private extension ScopeAtomRecoilContext {
  final class State {

    static let shared = State()
    let store = AtomStore()
    let token = ScopeKey.Token()
    let container = SubscriptionContainer()
    let notifier = PassthroughSubject<Void, Never>()
    var overrides = [OverrideKey: any AtomOverrideProtocol]()
    var onUpdate: (() -> Void)?

    func notifyUpdate() {
      onUpdate?()
      notifier.send()
    }
  }

  var store: StoreContext {
//    return StoreContext(state.store, observers: [], overrides: state.overrides.mapValues { $0.scoped(key: ScopeKey(token: state.token)) })
    @Dependency(\.storeContext) var store
    return store
//      .scoped(
//        weakStore: state.store,
//        key: ScopeKey(token: state.token),
//        observers: [],
//        overrides: state.overrides
//      )
  }

  var container: SubscriptionContainer.Wrapper {
    state.container.wrapper(location: location)
  }
}

extension ScopeAtomRecoilContext {
  public func useRecoilState<Node: StateAtom>(
    _ initialState: Node
  ) -> Binding<Node.Loader.Value> {
    ComposableArchitecture.useRecoilState(context: self, initialState)
  }

  // MARK: useRecoilState
  public func useRecoilState<Node: StateAtom>(
    _ initialState: @escaping() -> Node
  ) -> Binding<Node.Loader.Value> {
    ComposableArchitecture.useRecoilState(context: self, initialState)
  }
}
