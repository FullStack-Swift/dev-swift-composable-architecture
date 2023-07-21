import Foundation
import Combine

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
public func useRecoilTask<Node: TaskAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ updateStrategy: HookUpdateStrategy,
  _ initialNode: Node
) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
where Node.Loader: AsyncAtomLoader {
  useRecoilTask(fileID: fileID, line: line, updateStrategy) {
    initialNode
  }
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
public func useRecoilTask<Node: TaskAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ updateStrategy: HookUpdateStrategy,
  _ initialNode: @escaping() -> Node
) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
where Node.Loader: AsyncAtomLoader {
  useHook(
    RecoilTaskHook<Node>(
      updateStrategy: updateStrategy,
      initialNode: initialNode,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

private struct RecoilTaskHook<Node: TaskAtom>: Hook where Node.Loader: AsyncAtomLoader {
  
  typealias Value = AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
  
  let updateStrategy: HookUpdateStrategy?
  
  let initialNode: () -> Node
  
  let location: SourceLocation
  
  init(
    updateStrategy: HookUpdateStrategy,
    initialNode: @escaping () -> Node,
    location: SourceLocation
  ) {
    self.updateStrategy = updateStrategy
    self.initialNode = initialNode
    self.location = location
  }
  
  @MainActor
  func makeState() -> State {
    State(initialState: initialNode())
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Value {
    coordinator.state.context.objectWillChange
      .sink(receiveValue: coordinator.updateView)
      .store(in: &coordinator.state.cancellables)
    return coordinator.state.phase
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    coordinator.state.phase = .suspending
    coordinator.state.task = Task { @MainActor in
      let value = await coordinator.state.value
      if !Task.isCancelled {
        coordinator.state.phase = value
        coordinator.updateView()
      }
    }
  }
  
  @MainActor
  func dispose(state: State) {
    state.task = nil
    for cancellable in state.cancellables {
      cancellable.cancel()
    }
  }
}

extension RecoilTaskHook {
  // MARK: State
  final class State {
    
    @RecoilGlobalViewContext
    var context
    
    var node: Node
    var phase = Value.suspending
    
    var cancellables: SetCancellables = []
    var task: Task<Void, Never>? {
      didSet {
        oldValue?.cancel()
      }
    }
    
    init(initialState: Node) {
      self.node = initialState
    }
    
    /// Get current value from Recoilcontext
    var value: Value {
      get async {
        await AsyncPhase(context.watch(node).result)
      }
    }
  }
}
