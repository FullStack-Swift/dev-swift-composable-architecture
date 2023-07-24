import Foundation
import Combine

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func useRecoilThrowingTask<Node: ThrowingTaskAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ updateStrategy: HookUpdateStrategy = .once,
  _ initialState: Node
) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
where Node.Loader: AsyncAtomLoader {
  useRecoilThrowingTask(fileID: fileID, line: line, updateStrategy) {
    initialState
  }
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func useRecoilThrowingTask<Node: ThrowingTaskAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ updateStrategy: HookUpdateStrategy = .once,
  _ initialState: @escaping() -> Node
) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
where Node.Loader: AsyncAtomLoader {
  useHook(
    RecoilThrowingTaskHook<Node>(
      updateStrategy: updateStrategy,
      initialNode: initialState,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

private struct RecoilThrowingTaskHook<Node: ThrowingTaskAtom>: RecoilHook
where Node.Loader: AsyncAtomLoader {

  typealias State = _RecoilHookRef
  
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
    State(location: location, initialNode: initialNode())
  }

  @MainActor
  func value(coordinator: Coordinator) -> Value {
    coordinator.state.phase
  }

  @MainActor
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
    coordinator.recoilobservable()
    coordinator.state.context.observable.publisher.sink {
      Task { @MainActor in
        let result = await coordinator.state.value.result
        if !Task.isCancelled {
          guard !coordinator.state.isDisposed else {
            return
          }
          coordinator.state.phase = AsyncPhase(result)
          coordinator.updateView()
        }
      }
    }
    .store(in: &coordinator.state.cancellables)
    coordinator.state.task = Task { @MainActor in
      let refresh = await coordinator.state.refresh
      if !Task.isCancelled {
        guard !coordinator.state.isDisposed else {
          return
        }
        coordinator.state.phase = refresh
        coordinator.updateView()
      }
    }
  }

  @MainActor
  func dispose(state: State) {
    state.dispose()
  }
}

extension RecoilThrowingTaskHook {
  // MARK: State
  fileprivate final class _RecoilHookRef: RecoilHookRef<Node> {
    
    var phase = Value.suspending
    
    override init(location: SourceLocation, initialNode: Node) {
      super.init(location: location, initialNode: initialNode)
    }
    
    var value: Task<Node.Loader.Success, Node.Loader.Failure> {
      context.watch(node)
    }
    
    var refresh: Value {
      get async {
        await AsyncPhase(context.refresh(node).result)
      }
    }
  }
}
