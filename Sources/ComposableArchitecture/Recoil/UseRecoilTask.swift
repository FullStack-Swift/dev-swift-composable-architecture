import Foundation

// MARK: useRecoilTask
public func useRecoilTask<Node: TaskAtom>(
  _ updateStrategy: HookUpdateStrategy,
  _ initialState: Node
) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
where Node.Loader: AsyncAtomLoader {
  useRecoilTask(updateStrategy, {initialState})
}

public func useRecoilTask<Node: TaskAtom>(
  _ updateStrategy: HookUpdateStrategy,
  _ initialState: @escaping() -> Node
) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
where Node.Loader: AsyncAtomLoader {
  useHook(RecoilTaskHook<Node>(initialState: initialState, updateStrategy: updateStrategy))
}

private struct RecoilTaskHook<Node: TaskAtom>: Hook where Node.Loader: AsyncAtomLoader {
  
  typealias Value = AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
  
  let initialState: () -> Node
  let updateStrategy: HookUpdateStrategy?

  @MainActor
  func makeState() -> State {
    State(initialState: initialState())
  }

  @MainActor
  func value(coordinator: Coordinator) -> Value {
    coordinator.state.phase
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
  }
}

extension RecoilTaskHook {
  // MARK: State
  final class State {
    var state: Node
    @RecoilViewContext
    var context
    var phase = Value.suspending
    var task: Task<Void, Never>? {
      didSet {
        oldValue?.cancel()
      }
    }

    init(initialState: Node) {
      self.state = initialState
    }
    
    var value: Value {
      get async {
        await AsyncPhase(context.watch(state).result)
      }
    }
  }
}
