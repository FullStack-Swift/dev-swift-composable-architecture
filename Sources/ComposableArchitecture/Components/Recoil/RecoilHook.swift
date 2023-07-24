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

internal class RecoilHookRef<Node: Atom> {
  
  var node: Node
  var isDisposed = false
  
  internal var cancellables: SetCancellables = []
  
  @RecoilGlobalViewContext
  internal var context
  
  internal var task: Task<Void, Never>? {
    didSet {
      oldValue?.cancel()
    }
  }
  
  internal init(
    location: SourceLocation,
    initialNode: Node
  ) {
    node = initialNode
    _context = RecoilGlobalViewContext(location: location)
  }
  
  internal func dispose() {
    isDisposed = true
    task = nil
    cancellables.dispose()
  }
}

// MARK: HookCoordinator + Recoil
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
