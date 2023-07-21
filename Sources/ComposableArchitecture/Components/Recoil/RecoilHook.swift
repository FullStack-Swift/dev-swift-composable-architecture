import Foundation

public protocol RecoilHook: Hook {
  
  associatedtype Node: Atom
  
  var initialNode: () -> Node { get }
  
  var location: SourceLocation { get }
}

extension RecoilHook where State == RecoilHookRef<Node> {
  
  @MainActor
  func makeState() -> RecoilHookRef<Node> {
    RecoilHookRef(
      location: location,
      initialState: initialNode()
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
  
  private(set) var node: Node
  private(set) var isDisposed = false
  
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
    initialState: Node
  ) {
    node = initialState
    _context = RecoilGlobalViewContext(location: location)
  }
  
  internal func dispose() {
    isDisposed = true
    task = nil
    cancellables.dispose()
  }
}

internal extension RecoilHookRef
where Node: Atom {
  /// Get  value from RecoilGlobalContext
  @MainActor
  var value: Node.Loader.Value {
    context.watch(node)
  }
}

internal extension RecoilHookRef
where Node: ThrowingTaskAtom, Node.Loader: AsyncAtomLoader {
  /// Get value from RecoilGlobalContext
  var value: AsyncPhase<Node.Loader.Success, Node.Loader.Failure> {
    get async {
      await AsyncPhase(context.watch(node).result)
    }
  }
}

internal extension RecoilHookRef
where Node: TaskAtom, Node.Loader: AsyncAtomLoader {
  /// Get value from RecoilGlobalContext
  var value: AsyncPhase<Node.Loader.Success, Node.Loader.Failure> {
    get async {
      await AsyncPhase(context.watch(node).result)
    }
  }
}

// MARK: HookCoordinator + Recoil
extension HookCoordinator
where H: RecoilHook, H.State == RecoilHookRef<H.Node> {
  
  @MainActor
  func recoilUpdateView() {
    state.context.observable
      .sink {
        guard !state.isDisposed else {
          return
        }
        updateView()
      }
  }
}
