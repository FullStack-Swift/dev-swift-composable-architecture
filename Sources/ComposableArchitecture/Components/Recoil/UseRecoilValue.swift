import Foundation
import Combine

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialState: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func useRecoilValue<Node: Atom>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ initialState: Node
) -> Node.Loader.Value {
  useRecoilValue(fileID: fileID, line: line) {
    initialState
  }
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialState: initialState description
/// - Returns: description
@MainActor
public func useRecoilValue<Node: Atom>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ initialState: @escaping() -> Node
) -> Node.Loader.Value {
  useHook(RecoilValueHook<Node>(initialState: initialState))
}

private struct RecoilValueHook<Node: Atom>: Hook {
  
  typealias Value = Node.Loader.Value
  
  let initialState: () -> Node
  let updateStrategy: HookUpdateStrategy? = .once
  
  @MainActor
  func makeState() -> State {
    State(initialState: initialState())
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Value {
    coordinator.state.context.objectWillChange
      .sink(receiveValue: coordinator.updateView)
      .store(in: &coordinator.state.cancellables)
    return coordinator.state.value
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
  }
  
  @MainActor
  func dispose(state: State) {
    state.isDisposed = true
    for cancellable in state.cancellables {
      cancellable.cancel()
    }
  }
}

private extension RecoilValueHook {
  // MARK: State
  final class State {

    @RecoilGlobalViewContext
    var context

    var node: Node
    var cancellables: Set<AnyCancellable> = []
    var isDisposed = false

    init(initialState: Node) {
      self.node = initialState
    }

    /// Get current value from Recoilcontext
    @MainActor
    var value: Value {
      context.watch(node)
    }
  }
}
