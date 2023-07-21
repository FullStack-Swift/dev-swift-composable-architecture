import Combine

/// A hook to use the most recent phase of asynchronous operation of the passed publisher, and a `subscribe` function to subscribe to it at arbitrary timing.
///
///     let (phase, refresh) = usePublisherRefresh {
///         URLSession.shared.dataTaskPublisher(for: url)
///     }
///
/// - Parameter makePublisher: A closure that to create a new publisher to be subscribed.
/// - Returns: A tuple of the most recent publisher phase and its subscribe function.
@discardableResult
public func usePublisherRefresh<P: Publisher>(
  _ makePublisher: @escaping () -> P
) -> (phase: HookAsyncPhase<P.Output, P.Failure>, refresher: () -> Void) {
  useHook(PublisherSubscribeHook(makePublisher: makePublisher))
}

private struct PublisherSubscribeHook<P: Publisher>: Hook {
  
  typealias Phase = HookAsyncPhase<P.Output, P.Failure>
  
  let makePublisher: () -> P
  let updateStrategy: HookUpdateStrategy? = .once
  
  func makeState() -> State {
    State()
  }
  
  func value(coordinator: Coordinator) -> (phase: Phase, refresher: () -> Void) {
    (
      phase: coordinator.state.phase,
      refresher: {
        assertMainThread()
        
        guard !coordinator.state.isDisposed else {
          return
        }
        
        coordinator.state.phase = .running
        
        coordinator.state.cancellable = makePublisher()
          .sink(
            receiveCompletion: { completion in
              switch completion {
                case .failure(let error):
                  coordinator.state.phase = .failure(error)
                  coordinator.updateView()
                  
                case .finished:
                  break
              }
            },
            receiveValue: { output in
              coordinator.state.phase = .success(output)
              coordinator.updateView()
            }
          )
      }
    )
  }
  
  func dispose(state: State) {
    state.isDisposed = true
    state.cancellable = nil
  }
}

private extension PublisherSubscribeHook {
  final class State {
    var phase = Phase.pending
    var isDisposed = false
    var cancellable: AnyCancellable?
  }
}
