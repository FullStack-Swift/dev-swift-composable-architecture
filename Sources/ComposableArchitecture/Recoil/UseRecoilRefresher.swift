import Combine
import Foundation

// MARK: useRecoilRefresher
public func useRecoilRefresher<Node: PublisherAtom>(
  _ initialState: Node
) -> (phase: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>, refresher: () -> ())
where Node.Loader == PublisherAtomLoader<Node> {
  useRecoilRefresher {
    initialState
  }
}

// MARK: useRecoilRefresher
public func useRecoilRefresher<Node: PublisherAtom>(
  _ initialState: @escaping() -> Node
) -> (phase: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>, refresher: () -> ())
where Node.Loader == PublisherAtomLoader<Node> {
  useHook(RecoilRefresherHook(initialState: initialState, updateStrategy: nil))
}

private struct RecoilRefresherHook<Node: PublisherAtom>: Hook
where Node.Loader == PublisherAtomLoader<Node> {

  typealias Value = (phase: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>, refresher: () -> Void)

  let initialState: () -> Node
  let updateStrategy: HookUpdateStrategy?

  @MainActor
  func makeState() -> State {
    State(initialState: initialState())
  }

  @MainActor
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
//    coordinator.state.phase = coordinator.state.value
  }

  @MainActor
  func value(coordinator: Coordinator) -> Value {
    (
    coordinator.state.phase,
    refresher: {
      coordinator.state.phase = .suspending
      coordinator.updateView()
      Task { @MainActor in
        let refresh = await coordinator.state.refresh
        guard !coordinator.state.isDisposed else {
          return
        }
        coordinator.state.phase = refresh
        coordinator.updateView()
      }
    }
    )
  }

  @MainActor
  func dispose(state: State) {
    state.isDisposed = true
  }
}

extension RecoilRefresherHook {
  @MainActor
  final class State {
    @RecoilViewContext
    var context
    var state: Node
    var phase: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure> = .suspending
    var isDisposed = false
    init(initialState: Node) {
      self.state = initialState
    }

    /// Get current value from RecoilContext
    var value: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure> {
      context.watch(state)
    }


    /// Refresh to get newValue from RecoilContext
    var refresh: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure> {
      get async {
        await context.refresh(state)
      }
    }
  }
}
