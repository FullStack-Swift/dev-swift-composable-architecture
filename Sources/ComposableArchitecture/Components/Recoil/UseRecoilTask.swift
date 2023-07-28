/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
///
///```swift
///struct AsyncTextAtom: TaskAtom, Hashable {
///  func value(context: Context) async throws -> String {
///    try! await Task.sleep(nanoseconds: 1_000_000_000)
///    return "Swift"
///  }
///}
///
///
///struct TextContentView: View {
///  var body: some View {
///    HookScope {
///      let phase = useRecoilTask(AsyncTextAtom())
///      AsyncPhaseView(phase: phase) { value in
///        Text(value)
///      } suspending: {
///        ProgressView()
///      } failureContent: { error in
///        Text(error.localizedDescription)
///      }
///    }
///  }
///}
///```
@MainActor
public func useRecoilTask<Node: TaskAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy = .once,
  _ initialNode: Node
) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
where Node.Loader: AsyncAtomLoader {
  useRecoilTask(fileID: fileID, line: line, updateStrategy: updateStrategy) {
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
///
///```swift
///struct AsyncTextAtom: TaskAtom, Hashable {
///  func value(context: Context) async throws -> String {
///    try! await Task.sleep(nanoseconds: 1_000_000_000)
///    return "Swift"
///  }
///}
///
///
///struct TextContentView: View {
///  var body: some View {
///    HookScope {
///      let phase = useRecoilTask(AsyncTextAtom())
///      AsyncPhaseView(phase: phase) { value in
///        Text(value)
///      } suspending: {
///        ProgressView()
///      } failureContent: { error in
///        Text(error.localizedDescription)
///      }
///    }
///  }
///}
///```
@MainActor
public func useRecoilTask<Node: TaskAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy = .once,
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

private struct RecoilTaskHook<Node: TaskAtom>: RecoilHook where Node.Loader: AsyncAtomLoader {
  
  typealias State = _RecoilHookRef
  
  typealias Value = AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
  
  let updateStrategy: HookUpdateStrategy?
  
  let initialNode: () -> Node
  
  let location: SourceLocation
  
  init(
    updateStrategy: HookUpdateStrategy = .once,
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

private extension RecoilTaskHook {
  // MARK: State
  final class _RecoilHookRef: RecoilHookRef<Node> {
    
    var phase: Value = .suspending
    
    var value: Value {
      context.watch(node.phase)
    }
    
    var refresh: Value {
      get async {
        await AsyncPhase(context.refresh(node).result)
      }
    }
  }
}
