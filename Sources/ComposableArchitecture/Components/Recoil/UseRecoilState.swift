import SwiftUI

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
///
///```swift
///struct ThrowingAsyncTextAtom: ThrowingTaskAtom, Hashable {
///  func value(context: Context) async throws -> String {
///    try await Task.sleep(nanoseconds: 1_000_000_000)
///    return "Swift"
///  }
///}
///
///
///struct TextContentView: View {
///  var body: some View {
///    HookScope {
///      let phase = useRecoilThrowingTask(ThrowingAsyncTextAtom())
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
public func useRecoilState<Node: StateAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: Node
) -> Binding<Node.Loader.Value> {
  useRecoilState(fileID: fileID, line: line, updateStrategy: updateStrategy) {
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
///struct ThrowingAsyncTextAtom: ThrowingTaskAtom, Hashable {
///  func value(context: Context) async throws -> String {
///    try await Task.sleep(nanoseconds: 1_000_000_000)
///    return "Swift"
///  }
///}
///
///
///struct TextContentView: View {
///  var body: some View {
///    HookScope {
///      let phase = useRecoilThrowingTask(ThrowingAsyncTextAtom())
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
public func useRecoilState<Node: StateAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: @escaping() -> Node
) -> Binding<Node.Loader.Value> {
  useHook(
    RecoilStateHook<Node>(
      updateStrategy: updateStrategy,
      initialNode: initialNode,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

private struct RecoilStateHook<Node: StateAtom>: RecoilHook {
  
  typealias State = RecoilHookRef<Node>
  
  typealias Value = Binding<Node.Loader.Value>
  
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
    coordinator.state.context.observable.publisher.sink {
      guard !coordinator.state.isDisposed else {
        return
      }
      coordinator.updateView()
    }
    .store(in: &coordinator.state.cancellables)
  }
}

fileprivate extension RecoilHookRef {
  @MainActor
  var value: Node.Loader.Value {
    context.watch(node)
  }
}
