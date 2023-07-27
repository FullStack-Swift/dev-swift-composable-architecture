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
  
  typealias State = _HookRef
  
  typealias Phase = HookAsyncPhase<P.Output, P.Failure>
  
  typealias Value = (phase: Phase, refresher: () -> Void)
  
  let updateStrategy: HookUpdateStrategy? = .once
  
  let makePublisher: () -> P
  
  func makeState() -> State {
    State()
  }
  
  func value(coordinator: Coordinator) -> Value {
    let phase = coordinator.state.phase
    let refresher: () -> Void = {
      guard !coordinator.state.isDisposed else {
        return
      }
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
          receiveValue: { value in
            guard !coordinator.state.isDisposed else {
              return
            }
            coordinator.state.phase = .success(value)
            coordinator.updateView()
          }
        )
    }
    return (phase, refresher)
  }
  
  func dispose(state: State) {
    state.dispose()
  }
}

private extension PublisherSubscribeHook {
  // MARK: State
  final class _HookRef {
    
    var phase: Phase = .pending
    
    var isDisposed = false
    
    var cancellable: AnyCancellable?
    
    func dispose() {
      isDisposed = true
      cancellable = nil
    }
  }
}
