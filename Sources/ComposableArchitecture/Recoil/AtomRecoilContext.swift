import Combine
import Foundation

@MainActor
public struct AtomRecoilContext: AtomWatchableContext {
  private let state = State.identity
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

private extension AtomRecoilContext {
  final class State {

    static let identity = State()

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
    @Dependency(\.recoilStoreContext) var store
    return store
      .scoped(
        weakStore: state.store,
        key: ScopeKey(token: state.token),
        observers: [],
        overrides: state.overrides
      )
  }
  
  var container: SubscriptionContainer.Wrapper {
    state.container.wrapper(location: location)
  }
}
