import Foundation

// MARK: useRecoilThrowingTask
public func useRecoilThrowingTask<Node: ThrowingTaskAtom>(
  _ updateStrategy: HookUpdateStrategy,
  _ initialState: Node
) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
where Node.Loader: AsyncAtomLoader {
  useRecoilThrowingTask(updateStrategy, {initialState})
}

// MARK: useRecoilThrowingTask
public func useRecoilThrowingTask<Node: ThrowingTaskAtom>(
  _ updateStrategy: HookUpdateStrategy,
  _ initialState: @escaping() -> Node
) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
where Node.Loader: AsyncAtomLoader {
  useHook(
    RecoilThrowingTaskHook<Node>(
      initialState: initialState,
      updateStrategy: updateStrategy
    )
  )
}

private struct RecoilThrowingTaskHook<Node: ThrowingTaskAtom>: Hook
where Node.Loader: AsyncAtomLoader {
  
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

extension RecoilThrowingTaskHook {
  // MARK: State
  final class State {

    @RecoilGlobalViewContext
    var context

    var node: Node
    var phase = Value.suspending

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
