import Combine
import Foundation

public struct EffectMiddleware<State, Action>: MiddlewareProtocol {

  @usableFromInline
  let handle: (State, Action, ActionSource) -> EffectTask<Action>

  @usableFromInline
  init(
    internal handle: @escaping (State, Action, ActionSource) -> EffectTask<Action>
  ) {
    self.handle = handle
  }

  @inlinable
  public init(_ handle: @escaping (State, Action, ActionSource) -> EffectTask<Action>) {
    self.init(internal: handle)
  }

  public func handle(state: State, action: Action, from dispatcher: ActionSource) -> IO<Action> {
    let io = IO<Action> { output in
      let effect = self.handle(state, action, dispatcher)
      effect.sink { input in
        output.dispatch(input)
      }
      .store(in: &_cancellationEffectCancellables)
    }
    return io
  }
}

fileprivate var _cancellationEffectCancellables = Set<AnyCancellable>()
