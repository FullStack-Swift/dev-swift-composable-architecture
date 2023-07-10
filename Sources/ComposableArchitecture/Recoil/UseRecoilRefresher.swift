import Combine
import Foundation

// MARK: useRecoilRefresher + Publisher
public func useRecoilRefresher<Node: PublisherAtom>(
  _ initialState: Node
) -> (phase: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>, refresher: () -> ())
where Node.Loader == PublisherAtomLoader<Node> {
  useRecoilRefresher {
    initialState
  }
}

// MARK: useRecoilRefresher + Publisher
public func useRecoilRefresher<Node: PublisherAtom>(
  _ initialState: @escaping() -> Node
) -> (phase: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>, refresher: () -> ())
where Node.Loader == PublisherAtomLoader<Node> {
  useHook(RecoilPublisherRefresherHook(initialState: initialState, updateStrategy: nil))
}

// MARK: useRecoilRefresher + Task
public func useRecoilRefresher<Node: TaskAtom>(
  _ initialState: Node
) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
where Node.Loader: AsyncAtomLoader {
  useRecoilRefresher {
    initialState
  }
}

// MARK: useRecoilRefresher + Task
public func useRecoilRefresher<Node: TaskAtom>(
  _ initialState: @escaping() -> Node
) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
where Node.Loader: AsyncAtomLoader {
  useHook(RecoilTaskRefresherHook(initialState: initialState, updateStrategy: nil))
}

// MARK: useRecoilRefresher + ThrowingTask
public func useRecoilRefresher<Node: ThrowingTaskAtom>(
  _ initialState: Node
) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
where Node.Loader: AsyncAtomLoader {
  useRecoilRefresher {
    initialState
  }
}

// MARK: useRecoilRefresher + ThrowingTask
public func useRecoilRefresher<Node: ThrowingTaskAtom>(
  _ initialState: @escaping() -> Node
) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
where Node.Loader: AsyncAtomLoader {
  useHook(RecoilThrowingTaskRefresherHook(initialState: initialState, updateStrategy: nil))
}


// MARK: Private

private struct RecoilPublisherRefresherHook<Node: PublisherAtom>: Hook
where Node.Loader == PublisherAtomLoader<Node> {

  typealias Phase = AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>
  
  typealias Value = (phase: Phase, refresher: () -> Void)

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
  }

  @MainActor
  func value(coordinator: Coordinator) -> Value {
    coordinator.state.context.objectWillChange
      .sink(receiveValue: coordinator.updateView)
      .store(in: &coordinator.state.cancellables)
    return (
    coordinator.state.phase,
    refresher: {
//      coordinator.state.phase = .suspending
//      coordinator.updateView()
      Task { @MainActor in
        let refresh = await coordinator.state.refresh
        guard !coordinator.state.isDisposed else {
          return
        }
        if !Task.isCancelled {
          coordinator.state.phase = refresh
          coordinator.updateView()
        }
      }
    }
    )
  }

  @MainActor
  func dispose(state: State) {
    state.isDisposed = true
    for cancellable in state.cancellables {
      cancellable.cancel()
    }
  }
}

extension RecoilPublisherRefresherHook {
  @MainActor
  final class State {
    @RecoilGlobalViewContext
    var context
    var node: Node
    var phase: Phase = .suspending
    var cancellables: Set<AnyCancellable> = []
    var isDisposed = false
    init(initialState: Node) {
      self.node = initialState
    }

    /// Get current value from RecoilContext
    var value: Phase {
      context.watch(node)
    }


    /// Refresh to get newValue from RecoilContext
    var refresh: Phase {
      get async {
        await context.refresh(node)
      }
    }
  }
}

private struct RecoilTaskRefresherHook<Node: TaskAtom>: Hook
where Node.Loader: AsyncAtomLoader {

  typealias Phase = AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
  
  typealias Value = (Phase, refresher: () -> ())

  let initialState: () -> Node
  let updateStrategy: HookUpdateStrategy?

  @MainActor
  func makeState() -> State {
    State(initialState: initialState())
  }

  @MainActor
  func value(coordinator: Coordinator) -> Value {
    (
      coordinator.state.phase,
      refresher: {
        coordinator.state.phase = .suspending
//        coordinator.updateView()
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
    state.isDisposed = true
  }
}

extension RecoilTaskRefresherHook {
  // MARK: State
  final class State {
    var state: Node
    @RecoilGlobalViewContext
    var context
    var isDisposed = false
    var phase = Phase.suspending
    var task: Task<Void, Never>? {
      didSet {
        oldValue?.cancel()
      }
    }

    init(initialState: Node) {
      self.state = initialState
    }

    /// Get current value from Recoilcontext
    var value: Phase {
      get async {
        await AsyncPhase(context.watch(state).result)
      }
    }

    /// Refresh to get newValue from RedoilContext
    var refresh: Phase {
      get async  {
        await AsyncPhase(context.refresh(state).result)
      }
    }
  }
}

private struct RecoilThrowingTaskRefresherHook<Node: ThrowingTaskAtom>: Hook
where Node.Loader: AsyncAtomLoader {

  typealias Phase = AsyncPhase<Node.Loader.Success, Node.Loader.Failure>

  typealias Value = (Phase, refresher: () -> Void)

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
    return (
      coordinator.state.phase,
      refresher: {
        coordinator.state.phase = .suspending
//        coordinator.updateView()
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
    state.isDisposed = true
    for cancellable in state.cancellables {
      cancellable.cancel()
    }
  }
}

extension RecoilThrowingTaskRefresherHook {
  final class State {

    @RecoilGlobalViewContext
    var context
    
    var state: Node
    var phase = Phase.suspending
    var isDisposed = false
    var cancellables: Set<AnyCancellable> = []
    var task: Task<Void, Never>? {
      didSet {
        oldValue?.cancel()
      }
    }

    init(initialState: Node) {
      self.state = initialState
    }

    /// Get current value from Recoilcontext
    var value: Phase {
      get async {
        await AsyncPhase(context.watch(state).result)
      }
    }

    /// Refresh to get newValue from RedoilContext
    var refresh: Phase {
      get async {
        await AsyncPhase(context.refresh(state).result)
      }
    }
  }
}
