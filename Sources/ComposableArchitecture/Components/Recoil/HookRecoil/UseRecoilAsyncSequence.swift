/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilAsyncSequence<Node: AsyncSequenceAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: Node
) -> AsyncPhase<Node.Sequence.Element, Error>
where Node.Loader == AsyncSequenceAtomLoader<Node> {
  useRecoilAsyncSequence(fileID: fileID, line: line, updateStrategy: updateStrategy) {
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
public func useRecoilAsyncSequence<Node: AsyncSequenceAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: @escaping() -> Node
) -> AsyncPhase<Node.Sequence.Element, Error>
where Node.Loader == AsyncSequenceAtomLoader<Node> {
  useHook(
    RecoilAsyncSequenceHook<Node>(
      updateStrategy: updateStrategy,
      initialNode: initialNode,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

private struct RecoilAsyncSequenceHook<Node: AsyncSequenceAtom>: RecoilHook
where Node.Loader == AsyncSequenceAtomLoader<Node> {
  
  typealias State = _RecoilHookRef
  
  typealias Value = AsyncPhase<Node.Sequence.Element, Error>
  
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
    return coordinator.state.value
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
      coordinator.updateView()
    }
    .store(in: &coordinator.state.cancellables)
  }
  
  @MainActor
  func dispose(state: State) {
    state.dispose()
  }
}

private extension RecoilAsyncSequenceHook {
  // MARK: State
  final class _RecoilHookRef: RecoilHookRef<Node> {
    
    var value: Value {
      context.watch(node)
    }
  }
}
