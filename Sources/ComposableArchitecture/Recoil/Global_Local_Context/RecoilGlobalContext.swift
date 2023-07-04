import Combine
import SwiftUI
import Foundation

@MainActor
public struct RecoilGlobalContext: AtomWatchableContext {
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

private extension RecoilGlobalContext {
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

extension RecoilGlobalContext: RecoilProtocol {
  public var context: Self {
    self
  }
}

// MARK: View Unit

@propertyWrapper
@MainActor
public struct RecoilGlobalViewContext {
  
  @Dependency(\.storeContext)
  private var _store
  
  private let location: SourceLocation
  
  public init(fileID: String = #fileID, line: UInt = #line) {
    location = SourceLocation(fileID: fileID, line: line)
  }
  
  public var wrappedValue: RecoilGlobalContext {
    RecoilGlobalContext(fileID: location.fileID, line: location.line)
  }
}

@propertyWrapper
struct RecoilGlobalWatch<Node: Atom> {
  private let atom: Node
  
  @RecoilGlobalViewContext
  private var context
  
  public init(_ atom: Node, fileID: String = #fileID, line: UInt = #line) {
    self.atom = atom
    self._context = RecoilGlobalViewContext(fileID: fileID, line: line)
  }
  
  public var wrappedValue: Node.Loader.Value {
    context.watch(atom)
  }
}


@propertyWrapper
struct RecoilGlobalWatchState<Node: StateAtom> {
  private let atom: Node
  
  @RecoilGlobalViewContext
  private var context
  
  public init(_ atom: Node, fileID: String = #fileID, line: UInt = #line) {
    self.atom = atom
    self._context = RecoilGlobalViewContext(fileID: fileID, line: line)
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
  
  @RecoilGlobalViewContext
  private var context
  
  public init(_ atom: Node, fileID: String = #fileID, line: UInt = #line) {
    self.atom = atom
    self._context = RecoilGlobalViewContext(fileID: fileID, line: line)
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
public struct RecoilGlobalProvider<Content: View>: View {
  
  private let content: (RecoilGlobalContext) -> Content
  
  @RecoilGlobalViewContext
  private var context
  
  public init(@ViewBuilder _ content: @escaping (RecoilGlobalContext) -> Content) {
    self.content = content
  }
  
  public var body: some View {
    HookScope {
      content(context)
    }
  }
}

/// A view that wrapper around the `HookScope` to use hooks inside.
/// The view that is returned from `recoilBody` will be encluded with `HookScope` and be able to use hooks.
///
///     struct ContentView: RecoilView {
///         var recoilBody: some View {
///             let count = useState(0)
///
///             Button("\(count.wrappedValue)") {
///                 count.wrappedValue += 1
///             }
///         }
///     }

@MainActor
public protocol RecoilGlobalView: View {
  // The type of view representing the body of this view that can use recoil.
  associatedtype RecoilBody: View
  
  /// The content and behavior of the hook scoped view.
  @ViewBuilder
  func recoilBody(context: RecoilGlobalContext) -> RecoilBody
}

extension RecoilGlobalView {
  /// The content and behavior of the view.
  public var body: some View {
    HookScope {
      recoilBody(context: context)
    }
  }
  
  @MainActor
  var context: RecoilGlobalContext {
    @RecoilGlobalViewContext
    var context
    return context
  }
}
