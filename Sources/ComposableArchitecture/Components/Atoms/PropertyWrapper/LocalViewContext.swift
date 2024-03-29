import Combine
import SwiftUI
import Foundation

@available(*, deprecated, message: "use `LocalViewContext instead.")
public typealias LocalViewModel = LocalViewContext

@propertyWrapper
public struct LocalViewContext: DynamicProperty {
  @StateObject
  private var state = State()

  private let location: SourceLocation
  
  init(location: SourceLocation) {
    self.location = location
  }
  
  public init(fileID: String = #fileID, line: UInt = #line) {
    location = SourceLocation(fileID: fileID, line: line)
  }

  public var wrappedValue: AtomLocalViewContext {
    AtomLocalViewContext(
      store: StoreContext.scoped(
        key: ScopeKey(token: state.token),
        store: state.store,
        observers: [],
        overrides: [:]
      ),
      container: state.container.wrapper(location: location)
    ) {
      state.objectWillChange.send()
    }
  }
  
  public var projectedValue: Self {
    self
  }
}

private extension LocalViewContext {
  @MainActor
  final class State: ObservableObject {
    let container = SubscriptionContainer()
    let store = AtomStore()
    let token = ScopeKey.Token()
  }
}

//@propertyWrapper
//public struct LocalWatch<Node: Atom>: DynamicProperty {
//  private let atom: Node
//  
//  @LocalViewContext
//  private var context
//  
//  public init(_ atom: Node, fileID: String = #fileID, line: UInt = #line) {
//    self.atom = atom
//    self._context = LocalViewContext(fileID: fileID, line: line)
//  }
//  
//  public init(context: LocalViewContext,_ atom: Node) {
//    self.atom = atom
//    self._context = context
//  }
//
//  public var wrappedValue: Node.Loader.Value {
//    context.watch(atom)
//  }
//}
//
//// MARK: LocalWatchState
//@propertyWrapper
//public struct LocalWatchState<Node: StateAtom>: DynamicProperty {
//  private let atom: Node
//  
//  @LocalViewContext
//  private var context
//  
//  public init(_ atom: Node, fileID: String = #fileID, line: UInt = #line) {
//    self.atom = atom
//    self._context = LocalViewContext(fileID: fileID, line: line)
//  }
//  
//  public init(context: LocalViewContext,_ atom: Node) {
//    self.atom = atom
//    self._context = context
//  }
//
//  public var wrappedValue: Node.Loader.Value {
//    get { context.watch(atom) }
//    nonmutating set { context.set(newValue, for: atom) }
//  }
//
//  public var projectedValue: Binding<Node.Loader.Value> {
//    context.state(atom)
//  }
//}
//
//// MARK: LocalWatchStateObject
//@propertyWrapper
//public struct LocalWatchStateObject<Node: ObservableObjectAtom>: DynamicProperty {
//
//  @dynamicMemberLookup
//  public struct Wrapper {
//    private let object: Node.Loader.Value
//
//    public subscript<T>(
//      dynamicMember keyPath: ReferenceWritableKeyPath<Node.Loader.Value, T>
//    ) -> Binding<T> {
//      Binding(
//        get: { object[keyPath: keyPath] },
//        set: { object[keyPath: keyPath] = $0 }
//      )
//    }
//    
//    fileprivate init(_ object: Node.Loader.Value) {
//      self.object = object
//    }
//  }
//  
//  private let atom: Node
//  
//  @LocalViewContext
//  private var context
//
//  public init(_ atom: Node, fileID: String = #fileID, line: UInt = #line) {
//    self.atom = atom
//    self._context = LocalViewContext(fileID: fileID, line: line)
//  }
//  
//  public init(context: LocalViewContext,_ atom: Node) {
//    self.atom = atom
//    self._context = context
//  }
//
//  public var wrappedValue: Node.Loader.Value {
//    context.watch(atom)
//  }
//  
//  public var projectedValue: Wrapper {
//    Wrapper(wrappedValue)
//  }
//}

@MainActor
public struct AtomLocalViewContext: AtomWatchableContext {
  @usableFromInline
  internal let _store: StoreContext
  @usableFromInline
  internal let _container: SubscriptionContainer.Wrapper
  @usableFromInline
  internal let _notifyUpdate: () -> Void
  
  internal init(
    store: StoreContext,
    container: SubscriptionContainer.Wrapper,
    notifyUpdate: @escaping () -> Void
  ) {
    _store = store
    _container = container
    _notifyUpdate = notifyUpdate
  }
  
  /// A callback to perform when any of atoms watched by this context is updated.
  private let notifier = PassthroughSubject<Void, Never>()
  public var objectWillChange: AnyPublisher<Void, Never> {
    notifier.eraseToAnyPublisher()
  }
  
  @inlinable
  public func read<Node: Atom>(_ atom: Node) -> Node.Loader.Value {
    _store.read(atom)
  }
  
  @inlinable
  public func set<Node: StateAtom>(_ value: Node.Loader.Value, for atom: Node) {
    _store.set(value, for: atom)
  }
  
  @inlinable
  public func modify<Node: StateAtom>(_ atom: Node, body: (inout Node.Loader.Value) -> Void) {
    _store.modify(atom, body: body)
  }
 
  @discardableResult
  @inlinable
  public func refresh<Node: Atom>(_ atom: Node) async -> Node.Loader.Value where Node.Loader: RefreshableAtomLoader {
    await _store.refresh(atom)
  }
  
  @inlinable
  public func reset(_ atom: some Atom) {
    _store.reset(atom)
  }
  
  @discardableResult
  @inlinable
  public func watch<Node: Atom>(_ atom: Node) -> Node.Loader.Value {
    _store.watch(
      atom,
      container: _container,
      requiresObjectUpdate: false,
      notifyUpdate: _notifyUpdate
    )
  }

  @discardableResult
  @inlinable
  public func snapshot() -> Snapshot {
    _store.snapshot()
  }

  @inlinable
  public func restore(_ snapshot: Snapshot) {
    _store.restore(snapshot)
  }
}
