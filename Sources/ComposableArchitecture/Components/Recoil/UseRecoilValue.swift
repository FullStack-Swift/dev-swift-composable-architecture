/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
///
///```swift
///
///let value = useRecoilValue(TextAtom())
///
///print(value) // Prints the current value associated with ``TextAtom``.
///
///```
///
@MainActor
public func useRecoilValue<Node: Atom>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: Node
) -> Node.Loader.Value {
  useRecoilValue(fileID: fileID, line: line, updateStrategy: updateStrategy) {
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
///let context = ...
///
///let value = useRecoilValue{TextAtom()}
///
///print(value) // Prints the current value associated with ``TextAtom``.
///
///```
///
@MainActor
public func useRecoilValue<Node: Atom>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: @escaping() -> Node
) -> Node.Loader.Value {
  useHook(
    RecoilValueHook<Node>(
      updateStrategy: updateStrategy,
      initialNode: initialNode,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

private struct RecoilValueHook<Node: Atom>: RecoilHook {
  
  typealias State = RecoilHookRef<Node>
  
  typealias Value = Node.Loader.Value
  
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
    RecoilHookRef(location: location, initialNode: initialNode())
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
    coordinator.recoilobservable()
    coordinator.updateView()
  }
  
  @MainActor
  func dispose(state: State) {
    state.dispose()
  }
}

private extension RecoilHookRef {
  @MainActor
  var value: Node.Loader.Value {
    context.watch(node)
  }
}
