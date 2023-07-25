import Combine

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilRefresher<Node: PublisherAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: Node
) -> (phase: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>, refresher: () -> ())
where Node.Loader == PublisherAtomLoader<Node> {
  useRecoilRefresher(fileID: fileID, line: line, updateStrategy: updateStrategy) {
    initialNode
  }
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilRefresher<Node: PublisherAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: @escaping() -> Node
) -> (phase: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>, refresher: () -> ())
where Node.Loader == PublisherAtomLoader<Node> {
  useHook(
    RecoilPublisherRefresherHook(
      updateStrategy: updateStrategy,
      initialNode: initialNode,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilRefresher<Node: TaskAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: Node
) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
where Node.Loader: AsyncAtomLoader {
  useRecoilRefresher(fileID: fileID, line: line, updateStrategy: updateStrategy) {
    initialNode
  }
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilRefresher<Node: TaskAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: @escaping() -> Node
) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
where Node.Loader: AsyncAtomLoader {
  useHook(
    RecoilTaskRefresherHook<Node>(
      updateStrategy: updateStrategy,
      initialNode: initialNode,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}
/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilRefresher<Node: ThrowingTaskAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: Node
) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
where Node.Loader: AsyncAtomLoader {
  useRecoilRefresher(fileID: fileID, line: line, updateStrategy: updateStrategy) {
    initialNode
  }
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilRefresher<Node: ThrowingTaskAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: @escaping() -> Node
) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
where Node.Loader: AsyncAtomLoader {
  useHook(
    RecoilThrowingTaskRefresherHook(
      updateStrategy: updateStrategy,
      initialNode: initialNode,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

// MARK: Recoil Refresher Hook

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
        guard !coordinator.state.isDisposed else {
          return
        }
        coordinator.state.task = Task { @MainActor in
          let refresh = await coordinator.state.refresh
          if !Task.isCancelled && !coordinator.state.isDisposed {
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
      guard !coordinator.state.isDisposed else {
        return
      }
      coordinator.state.phase = coordinator.state.value
      coordinator.updateView()
    }
    .store(in: &coordinator.state.cancellables)
    coordinator.state.task = Task { @MainActor in
      let refresh = await coordinator.state.refresh
      if !Task.isCancelled && !coordinator.state.isDisposed {
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

private extension RecoilPublisherRefresherHook {
  // MARK: State
  final class _RecoilHookRef: RecoilHookRef<Node> {
    
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
            if !Task.isCancelled && !coordinator.state.isDisposed {
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
      guard !coordinator.state.isDisposed else {
        return
      }
      coordinator.state.task = Task { @MainActor in
        let value = await coordinator.state.value.result
        if !Task.isCancelled && !coordinator.state.isDisposed {
          coordinator.state.phase = AsyncPhase(value)
          coordinator.updateView()
        }
      }
    }
    .store(in: &coordinator.state.cancellables)
    coordinator.state.task = Task { @MainActor in
      let refresh = await coordinator.state.refresh
      if !Task.isCancelled && !coordinator.state.isDisposed {
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

private extension RecoilTaskRefresherHook {
  // MARK: State
  final class _RecoilHookRef: RecoilHookRef<Node> {
    
    var phase: Phase = .suspending
    
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
        guard !coordinator.state.isDisposed else {
          return
        }
        Task { @MainActor in
          let refresh = await coordinator.state.refresh
          if !Task.isCancelled && !coordinator.state.isDisposed {
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
      guard !coordinator.state.isDisposed else {
        return
      }
      coordinator.state.task = Task { @MainActor in
        let value = await coordinator.state.value.result
        if !Task.isCancelled && !coordinator.state.isDisposed {
          coordinator.state.phase = AsyncPhase(value)
        }
      }
    }
    .store(in: &coordinator.state.cancellables)
    coordinator.state.task = Task { @MainActor in
      let refresh = await coordinator.state.refresh
      if !Task.isCancelled && !coordinator.state.isDisposed {
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

private extension RecoilThrowingTaskRefresherHook {
  // MARK: State
  final class _RecoilHookRef: RecoilHookRef<Node> {
    
    var phase: Phase = .suspending
    
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
