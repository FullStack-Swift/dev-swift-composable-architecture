/// A hook to use memoized value preserved until it is updated at the timing determined with given `updateStrategy`.
///
///     let random = useMemo(.once) {
///         Int.random(in: 0...100)
///     }
///
/// - Parameters:
///   - updateStrategy: A strategy that determines when to update the value.
///   - makeValue: A closure that to create a new value.
/// - Returns: A memoized value.
public func useMemo<Node>(
  _ updateStrategy: HookUpdateStrategy = .once,
  _ initialNode: @escaping () -> Node
) -> Node {
  useHook(
    MemoHook(
      updateStrategy: updateStrategy,
      initialNode: initialNode
    )
  )
}

public func useMemo<Node>(
  _ updateStrategy: HookUpdateStrategy = .once,
  _ initialNode: Node
) -> Node {
  useMemo(updateStrategy, { initialNode })
}

private struct MemoHook<Node>: Hook {
  
  typealias State = _HookRef
  
  let updateStrategy: HookUpdateStrategy?
  
  let initialNode: () -> Node
  
  
  init(
    updateStrategy: HookUpdateStrategy?,
    initialNode: @escaping () -> Node
  ) {
    self.updateStrategy = updateStrategy
    self.initialNode = initialNode
  }
  
  func makeState() -> State {
    State()
  }
  
  func value(coordinator: Coordinator) -> Node {
    coordinator.state.node ?? initialNode()
  }
  
  func updateState(coordinator: Coordinator) {
    coordinator.state.node = initialNode()
  }
  
  func dispose(state: State) {
    state.dispose()
  }
}

private extension MemoHook {
  // MARK: State
  final class _HookRef {
    var node: Node?
    
    var isDisposed = false
    
    func dispose() {
      isDisposed = true
    }
  }
}
