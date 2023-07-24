import Combine
import Foundation

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func useRecoilRefresher<Node: PublisherAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ initialNode: Node
) -> (phase: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>, refresher: () -> ())
where Node.Loader == PublisherAtomLoader<Node> {
  useRecoilRefresher(fileID: fileID, line: line) {
    initialNode
  }
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func useRecoilRefresher<Node: PublisherAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ initialNode: @escaping() -> Node
) -> (phase: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>, refresher: () -> ())
where Node.Loader == PublisherAtomLoader<Node> {
  useHook(
    RecoilPublisherRefresherHook(
      updateStrategy: .once,
      initialNode: initialNode,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func useRecoilRefresher<Node: TaskAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ initialNode: Node
) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
where Node.Loader: AsyncAtomLoader {
  useRecoilRefresher(fileID: fileID, line: line) {
    initialNode
  }
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func useRecoilRefresher<Node: TaskAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ initialNode: @escaping() -> Node
) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
where Node.Loader: AsyncAtomLoader {
  useHook(
    RecoilTaskRefresherHook<Node>(
      updateStrategy: .once,
      initialNode: initialNode,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func useRecoilRefresher<Node: ThrowingTaskAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ initialNode: Node
) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
where Node.Loader: AsyncAtomLoader {
  useRecoilRefresher(fileID: fileID, line: line) {
    initialNode
  }
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func useRecoilRefresher<Node: ThrowingTaskAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ initialNode: @escaping() -> Node
) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
where Node.Loader: AsyncAtomLoader {
  useHook(
    RecoilThrowingTaskRefresherHook(
      updateStrategy: .once,
      initialNode: initialNode,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

// MARK: Private Refresher Hook

private struct RecoilPublisherRefresherHook<Node: PublisherAtom>: RecoilHook
where Node.Loader == PublisherAtomLoader<Node> {
  
  typealias State = _RecoilHookRef
  
  typealias Phase = AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>
  
  typealias Value = (phase: Phase, refresher: () -> Void)
  
  let initialNode: () -> Node
  
  let updateStrategy: HookUpdateStrategy?
  
  let location: SourceLocation
  
  init(
    updateStrategy: HookUpdateStrategy? = .once,
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
    coordinator.state.phase = coordinator.state.value
    return (
      coordinator.state.phase,
      refresher: {
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
    )
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
    coordinator.recoilobservable()
    coordinator.state.context.observable.publisher.sink {
      coordinator.state.phase = coordinator.state.value
      coordinator.updateView()
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

extension RecoilPublisherRefresherHook {
  // MARK: State
  fileprivate final class _RecoilHookRef: RecoilHookRef<Node> {
    
    var phase = Phase.suspending
    
    override init(location: SourceLocation, initialNode: Node) {
      super.init(location: location, initialNode: initialNode)
    }
    
    var value: Phase {
      context.watch(node)
    }
    
    var refresh: Phase {
      get async {
        await context.refresh(node)
      }
    }
  }
}

private struct RecoilTaskRefresherHook<Node: TaskAtom>: RecoilHook
where Node.Loader: AsyncAtomLoader {
  
  typealias State = _RecoilHookRef
  
  typealias Phase = AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
  
  typealias Value = (Phase, refresher: () -> ())
  
  let updateStrategy: HookUpdateStrategy?
  
  let initialNode: () -> Node
  
  let location: SourceLocation
  
  init(
    updateStrategy: HookUpdateStrategy? = .once,
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
    return (
      coordinator.state.phase,
      refresher: {
        Task { @MainActor in
          guard !coordinator.state.isDisposed else {
            return
          }
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
      }
    )
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
    coordinator.recoilobservable()
    coordinator.state.context.observable.publisher.sink {
      coordinator.state.task = Task { @MainActor in
        let value = await coordinator.state.value.result
        if !Task.isCancelled {
          guard !coordinator.state.isDisposed else {
            return
          }
          coordinator.state.phase = AsyncPhase(value)
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

extension RecoilTaskRefresherHook {
  // MARK: State
  fileprivate final class _RecoilHookRef: RecoilHookRef<Node> {
    
    var phase = Phase.suspending
    
    override init(location: SourceLocation, initialNode: Node) {
      super.init(location: location, initialNode: initialNode)
    }
    
    var value: Task<Node.Loader.Success, Node.Loader.Failure> {
      context.watch(node)
    }
    
    var refresh: Phase {
      get async {
        await AsyncPhase(context.refresh(node).result)
      }
    }
  }
}

private struct RecoilThrowingTaskRefresherHook<Node: ThrowingTaskAtom>: RecoilHook
where Node.Loader: AsyncAtomLoader {
  
  typealias State = _RecoilHookRef
  
  typealias Phase = AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
  
  typealias Value = (Phase, refresher: () -> Void)
  
  let updateStrategy: HookUpdateStrategy?
  
  let initialNode: () -> Node
  
  let location: SourceLocation
  
  @MainActor
  func makeState() -> State {
    State(location: location, initialNode: initialNode())
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Value {
    return (
      coordinator.state.phase,
      refresher: {
        Task { @MainActor in
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
    )
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
    coordinator.recoilobservable()
    coordinator.state.context.observable.publisher.sink {
      coordinator.state.task = Task { @MainActor in
        let value = await coordinator.state.value.result
        if !Task.isCancelled {
          guard !coordinator.state.isDisposed else {
            return
          }
          coordinator.state.phase = AsyncPhase(value)
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

extension RecoilThrowingTaskRefresherHook {
  // MARK: State
  fileprivate final class _RecoilHookRef: RecoilHookRef<Node> {
    
    var phase = Phase.suspending
    
    override init(location: SourceLocation, initialNode: Node) {
      super.init(location: location, initialNode: initialNode)
    }
    
    var value: Task<Node.Loader.Success, Node.Loader.Failure> {
      context.watch(node)
    }
    
    var refresh: Phase {
      get async {
        await AsyncPhase(context.refresh(node).result)
      }
    }
  }
}
