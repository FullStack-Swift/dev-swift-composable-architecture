import Foundation

public protocol RecoilHook: Hook {
  
  associatedtype Node: Atom
  
  var initialNode: () -> Node { get }
  
  var location: SourceLocation { get }
}

extension RecoilHook where State: RecoilHookRef<Node> {
  
  @MainActor
  func makeState() -> RecoilHookRef<Node> {
    RecoilHookRef(
      location: location,
      initialNode: initialNode()
    )
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
  }
  
  @MainActor
  func dispose(state: RecoilHookRef<Node>) {
    state.dispose()
  }
  
  @MainActor
  func context(coordinator: Coordinator) -> RecoilGlobalContext {
    coordinator.state.context
  }
}

@MainActor
internal class RecoilHookRef<Node: Atom> {
  
  internal var _context: RecoilGlobalViewContext
  
  internal var context: RecoilGlobalContext
  
  internal var node: Node
  
  internal var task: Task<Void, Never>? {
    didSet {
      oldValue?.cancel()
    }
  }
  
  internal var refreshViewCount: Int = 0
  
  internal var isDisposed = false
  
  internal var cancellables: SetCancellables = []
  
  internal init(
    location: SourceLocation,
    initialNode: Node
  ) {
    node = initialNode
    _context = RecoilGlobalViewContext(location: location)
    context = _context.wrappedValue
  }
  
  internal func dispose() {
    task = nil
    cancellables.dispose()
    isDisposed = true
  }
}

// MARK: HookCoordinator + Recoil + UpdateView
extension HookCoordinator
where H: RecoilHook, H.State: RecoilHookRef<H.Node> {
  
  @MainActor
  func recoilobservable() {
    state.cancellables.dispose()
    if !state.isDisposed {
      state.context.observable
        .objectWillChange
        .sink {
          guard !state.isDisposed else {
            return
          }
          updateView()
        }
        .store(in: &state.cancellables)
    }
  }
}
