import Foundation
import Combine

// MARK: useRecoilTask
public func useRecoilTask<Node: TaskAtom>(
  _ updateStrategy: HookUpdateStrategy,
  _ initialState: Node
) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
where Node.Loader: AsyncAtomLoader {
  useRecoilTask(updateStrategy, {initialState})
}

// MARK: useRecoilTask
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
    
    var cancellables: Set<AnyCancellable> = []
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
