import Combine

// MARK: Call operation only running `subscribe` action, It will updateUI status AsyncPhase.

/// A hook to use the most recent phase of asynchronous operation of the passed publisher, and a `subscribe` function to subscribe to it at arbitrary timing.
///
///     let (phase, subscribe) = usePublisherSubscribe {
///         URLSession.shared.dataTaskPublisher(for: url)
///     }
///
/// - Parameter makePublisher: A closure that to create a new publisher to be subscribed.
/// - Returns: A tuple of the most recent publisher phase and its subscribe function.
@discardableResult
public func usePublisherSubscribe<P: Publisher>(
  _ makePublisher: @escaping () -> P
) -> (
  phase: AsyncPhase<P.Output, P.Failure>,
  subscribe: () -> Void
) {
  useHook(PublisherSubscribeHook(makePublisher: makePublisher))
}

private struct PublisherSubscribeHook<P: Publisher>: Hook {
  
  typealias State = _HookRef
  
  typealias Phase = AsyncPhase<P.Output, P.Failure>
  
  typealias Value = (phase: Phase, subscribe: () -> Void)
  
  let updateStrategy: HookUpdateStrategy? = .once
  
  let makePublisher: () -> P
  
  func makeState() -> State {
    State()
  }
  
  func value(coordinator: Coordinator) -> Value {
    let phase = coordinator.state.phase
    let subscribe: () -> Void = {
      guard !coordinator.state.isDisposed else {
        return
      }
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
    return (phase, subscribe)
  }
  
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
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
