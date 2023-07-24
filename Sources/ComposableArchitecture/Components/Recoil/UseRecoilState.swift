import SwiftUI
import Combine

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func useRecoilState<Node: StateAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ initialNode: Node
) -> Binding<Node.Loader.Value> {
  useRecoilState(fileID: fileID, line: line) {
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
public func useRecoilState<Node: StateAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ initialNode: @escaping() -> Node
) -> Binding<Node.Loader.Value> {
  useHook(
    RecoilStateHook<Node>(
      initialNode: initialNode,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

private struct RecoilStateHook<Node: StateAtom>: RecoilHook {
  
  typealias State = RecoilHookRef<Node>
  
  typealias Value = Binding<Node.Loader.Value>
  
  let updateStrategy: HookUpdateStrategy? = .once
  
  let initialNode: () -> Node
  
  let location: SourceLocation

  init(initialNode: @escaping () -> Node, location: SourceLocation) {
    self.initialNode = initialNode
    self.location = location
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Value {
    return Binding(
      get: {
        coordinator.state.value
      },
      set: { newState, transaction in
        guard !coordinator.state.isDisposed else {
          return
        }
        withTransaction(transaction) {
          coordinator.state.context.set(newState, for: coordinator.state.node)
          coordinator.updateView()
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
  }
}

fileprivate extension RecoilHookRef {
  @MainActor
  var value: Node.Loader.Value {
    context.watch(node)
  }
}
