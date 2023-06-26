import Combine
import SwiftUI
import Foundation

@propertyWrapper
public struct ScopeRecoilViewContext: DynamicProperty {
  @StateObject
  private var state = State()
  
  private var overrides = [OverrideKey: any AtomOverrideProtocol]()
  private var observers = [Observer]()

  private let location: SourceLocation
  
  public init(fileID: String = #fileID, line: UInt = #line) {
    location = SourceLocation(fileID: fileID, line: line)
  }

  public var wrappedValue: ScopeAtomRecoilContext {
    ScopeAtomRecoilContext(
      store: StoreContext.scoped(
        key: ScopeKey(token: state.token),
        store: state.store,
        observers: observers,
        overrides: overrides
      ),
      container: state.container.wrapper(location: location)) {
        state.objectWillChange.send()
      }
  }
}

private extension ScopeRecoilViewContext {
  @MainActor
  final class State: ObservableObject {
    let container = SubscriptionContainer()
    let store = AtomStore()
    let token = ScopeKey.Token()

  }
}

@MainActor
public struct ScopeAtomRecoilContext: AtomWatchableContext {
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

extension ScopeAtomRecoilContext: RecoilProtocol {
  public var context: Self {
    self
  }
}
