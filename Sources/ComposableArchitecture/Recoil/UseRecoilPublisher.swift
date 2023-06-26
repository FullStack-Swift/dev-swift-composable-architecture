import Combine
import Foundation

// MARK: useRecoilPublihser
public func useRecoilPublisher<Node: PublisherAtom>(
  _ initialState: Node
) -> AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>
where Node.Loader == PublisherAtomLoader<Node> {
  useRecoilPublisher {
    initialState
  }
}

// MARK: useRecoilPublihser
public func useRecoilPublisher<Node: PublisherAtom>(
  _ initialState: @escaping() -> Node
) -> AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>
where Node.Loader == PublisherAtomLoader<Node> {
  useHook(RecoilPublisherHook(initialState: initialState, updateStrategy: nil))
}

private struct RecoilPublisherHook<Node: PublisherAtom>: Hook
where Node.Loader == PublisherAtomLoader<Node> {
  
  typealias Value = AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>
  
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
    coordinator.state.phase = coordinator.state.value
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Value {
    coordinator.state.phase
  }
  
  @MainActor
  func dispose(state: State) {
    state.isDisposed = true
  }
}

extension RecoilPublisherHook {
  @MainActor
  final class State {
    var state: Node
    @RecoilViewContext
    var context
    var phase = Value.suspending
    var isDisposed = false
    init(initialState: Node) {
      self.state = initialState
    }
    
    var value: Value {
      context.watch(state)
    }
  }
}
