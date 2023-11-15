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

private extension RecoilHookRef {
  @MainActor
  var value: Node.Loader.Value {
    context.read(node)
  }
}

@propertyWrapper
@MainActor public struct RecoilReadValue<Node: Atom> {
  
  public var wrappedValue: Node
  
  internal let _value: Node.Loader.Value
  
  public init(wrappedValue: Node) {
    self.wrappedValue = wrappedValue
    _value = useRecoilReadValue(updateStrategy: .once, wrappedValue)
  }
  
  public var projectedValue: Node.Loader.Value {
    _value
  }
}
