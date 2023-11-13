import Combine

// MARK: Call publisher only `updateStrategy` changes, It will updateUI status AsyncPhase.

/// A hook to use the most recent phase of asynchronous operation of the passed publisher.
/// The publisher will be subscribed at the first update and will be re-subscribed according to the given `updateStrategy`.
///
///     let phase = usePublisher(.once) {
///         URLSession.shared.dataTaskPublisher(for: url)
///     }
///
/// - Parameters:
///   - updateStrategy: A strategy that determines when to re-subscribe the given publisher.
///   - makePublisher: A closure that to create a new publisher to be subscribed.
/// - Returns: A most recent publisher phase.
@discardableResult
public func usePublisher<P: Publisher>(
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ makePublisher: @escaping () -> P
) -> AsyncPhase<P.Output, P.Failure> {
  useHook(
    PublisherHook(
      updateStrategy: updateStrategy,
      makePublisher: makePublisher
    )
  )
}

private struct PublisherHook<P: Publisher>: Hook {
  
  typealias State = _HookRef
  
  typealias Phase = AsyncPhase<P.Output, P.Failure>
  
  let updateStrategy: HookUpdateStrategy?
  
  let makePublisher: () -> P
  
  init(
    updateStrategy: HookUpdateStrategy? = .once,
    makePublisher: @escaping () -> P
  ) {
    self.updateStrategy = updateStrategy
    self.makePublisher = makePublisher
  }
  
  func makeState() -> State {
    State()
  }
  
  func updateState(coordinator: Coordinator) {
    coordinator.state.phase = .running
    coordinator.updateView()
    coordinator.state.cancellable = makePublisher()
      .sink(
        receiveCompletion: { completion in
          switch completion {
            case .failure(let error):
              guard !coordinator.state.isDisposed else {
                return
              }
              coordinator.state.phase = .failure(error)
              coordinator.updateView()
            case .finished:
              break
          }
        },
        receiveValue: { output in
          guard !coordinator.state.isDisposed else {
            return
          }
          coordinator.state.phase = .success(output)
          coordinator.updateView()
        }
      )
  }
  
  func value(coordinator: Coordinator) -> Phase {
    coordinator.state.phase
  }
  
  func dispose(state: State) {
    state.dispose()
  }
}

private extension PublisherHook {
  // MARK: State
  final class _HookRef {
    
    var phase: Phase = .pending
    
    var isDisposed = false
    
    var cancellable: AnyCancellable?
    
    func dispose() {
      cancellable = nil
      isDisposed = true
    }
  }
}
