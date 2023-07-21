import Foundation
import Combine

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func useRecoilValue<Node: Atom>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ initialNode: Node
) -> Node.Loader.Value {
  useRecoilValue(fileID: fileID, line: line) {
    initialNode
  }
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: description
@MainActor
public func useRecoilValue<Node: Atom>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ initialNode: @escaping() -> Node
) -> Node.Loader.Value {
  useHook(
    RecoilValueHook<Node>(
      initialNode: initialNode,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

private struct RecoilValueHook<Node: Atom>: RecoilHook {
  
  typealias State = RecoilHookRef<Node>
  
  typealias Value = Node.Loader.Value
  
  let updateStrategy: HookUpdateStrategy? = .once
  
  let initialNode: () -> Node
  
  let location: SourceLocation
  
  init(
    updateStrategy: HookUpdateStrategy? = .once,
    initialNode: @escaping () -> Node,
    location: SourceLocation
  ) {
    self.initialNode = initialNode
    self.location = location
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Value {
    coordinator.recoilUpdateView()
    return coordinator.state.value
  }
}
