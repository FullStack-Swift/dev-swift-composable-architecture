import SwiftUI
import Combine

// MARK: useRecoilState
public func useRecoilState<Node: StateAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ initialNode: Node
) -> Binding<Node.Loader.Value> {
  useRecoilState(fileID: fileID, line: line) {
    initialNode
  }
}

// MARK: useRecoilState
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
    coordinator.recoilUpdateView()
    return Binding(
      get: {
        coordinator.state.context.watch(coordinator.state.node)
      },
      set: { newState, transaction in
        assertMainThread()
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
}
