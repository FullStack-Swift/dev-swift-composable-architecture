import Combine
import Foundation

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: description
@MainActor
public func useRecoilPublisher<Node: PublisherAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ initialNode: Node
) -> AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>
where Node.Loader == PublisherAtomLoader<Node> {
  useRecoilPublisher(fileID: fileID, line: line) {
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
public func useRecoilPublisher<Node: PublisherAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ initialNode: @escaping() -> Node
) -> AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>
where Node.Loader == PublisherAtomLoader<Node> {
  useHook(
    RecoilPublisherHook<Node>(
      updateStrategy: .once,
      initialNode: initialNode,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

private struct RecoilPublisherHook<Node: PublisherAtom>: RecoilHook
where Node.Loader == PublisherAtomLoader<Node> {
  
  typealias State = _RecoilHookRef
  
  typealias Value = AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>
  
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
    coordinator.state.phase
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
//    coordinator.recoilobservable()
    coordinator.state.context.observable.publisher.sink {
      let value = coordinator.state.value
      guard !coordinator.state.isDisposed else {
        return
      }
      coordinator.state.phase = value
      coordinator.updateView()
    }
    .store(in: &coordinator.state.cancellables)
    coordinator.state.task = Task { @MainActor in
      let refresh = await coordinator.state.refresh
      if !Task.isCancelled {
        guard !coordinator.state.isDisposed else {
          return
        }
        coordinator.state.phase = refresh
        coordinator.updateView()
      }
    }
  }
  
  @MainActor
  func dispose(state: State) {
    state.dispose()
  }
}

extension RecoilPublisherHook {
  // MARK: State
  fileprivate final class _RecoilHookRef: RecoilHookRef<Node> {
    
    var phase = Value.suspending
    
    override init(location: SourceLocation, initialNode: Node) {
      super.init(location: location, initialNode: initialNode)
    }

    var value: Value {
      context.watch(node)
    }
    
    var refresh: Value {
      get async {
        await context.refresh(node)
      }
    }
  }
}
