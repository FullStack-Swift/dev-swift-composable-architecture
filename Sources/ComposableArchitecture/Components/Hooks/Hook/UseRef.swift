/// A hook to use a mutable ref object storing an arbitrary value.
/// The essential of this hook is that setting a value to `current` doesn't trigger a view update.
///
///     let value = useRef("text")  // RefObject<String>
///
///     Button("Save text") {
///         value.current = "new text"
///     }
///
/// - Parameter initialValue: A initial value that to initialize the ref object to be returned.
/// - Returns: A mutable ref object.
public func useRef<Node>(
  _ initialNode: Node
) -> RefObject<Node> {
  useHook(
    RefHook(
      initialNode: initialNode
    )
  )
}

public func useRef<Node>(
  _ initialNode: @escaping () -> Node
) -> RefObject<Node> {
  useHook(
    RefHook(
      initialNode: initialNode()
    )
  )
}

private struct RefHook<Node>: Hook {
  
  typealias State = RefObject<Node>
  
  typealias Value = RefObject<Node>
  
  let initialNode: Node
  
  var updateStrategy: HookUpdateStrategy? = .once
  
  func makeState() -> State {
    State(initialNode)
  }
  
  func value(coordinator: Coordinator) -> Value {
    coordinator.state
  }
  
  func updateState(coordinator: Coordinator) {
    
  }
  
  func dispose(state: State) {
    
  }
}
