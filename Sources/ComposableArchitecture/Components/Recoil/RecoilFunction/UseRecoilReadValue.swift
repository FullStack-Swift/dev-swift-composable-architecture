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
///let value = useRecoilReadValue(TextAtom())
///
///print(value) // Prints the current value associated with ``TextAtom``.
///
///```
///
@MainActor
public func useRecoilReadValue<Node: Atom>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: Node
) -> Node.Loader.Value {
  useRecoilReadValue(fileID: fileID, line: line, updateStrategy: updateStrategy) {
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
///let value = useRecoilReadValue{TextAtom()}
///
///print(value) // Prints the current value associated with ``TextAtom``.
///
///```
///
@MainActor
public func useRecoilReadValue<Node: Atom>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: @escaping() -> Node
) -> Node.Loader.Value {
  useHook(
    RecoilReadValueHook<Node>(
      updateStrategy: updateStrategy,
      initialNode: initialNode,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

private struct RecoilReadValueHook<Node: Atom>: RecoilHook {
  
  typealias State = _RecoilHookRef
  
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
    _RecoilHookRef(location: location, initialNode: initialNode())
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Value {
    coordinator.state.value
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
    coordinator.state.updateState()
  }
  
  @MainActor
  func dispose(state: State) {
    state.dispose()
  }
}

private extension RecoilReadValueHook {
  // MARK: State
  final class _RecoilHookRef: RecoilHookRef<Node> {
    
    var cache: Value?
    
    override init(location: SourceLocation, initialNode: Node) {
      super.init(location: location, initialNode: initialNode)
      updateState()
    }
    
    var value: Value {
      cache ?? _value
    }
    
    var _value: Value {
      context.read(node)
    }
    
    func updateState() {
      self.cache = _value
    }
  }
}
