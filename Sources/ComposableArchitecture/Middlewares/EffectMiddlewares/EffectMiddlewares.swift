import Combine
import Foundation

fileprivate var _cancellationEffectCancellables = Set<AnyCancellable>()

public struct EffectMiddleware<State, Action>: MiddlewareProtocol {

  @usableFromInline
  let handle: (Action, ActionSource, State) -> EffectTask<Action>

  @usableFromInline
  init(
    internal handle: @escaping (Action, ActionSource, State) -> EffectTask<Action>
  ) {
    self.handle = handle
  }

  @inlinable
  public init(_ handle: @escaping (Action, ActionSource, State) -> EffectTask<Action>) {
    self.init(internal: handle)
  }

  public func handle(action: Action, from dispatcher: ActionSource, state: State) -> IO<Action> {
    let io = IO<Action> { output in
      let effect = self.handle(action, dispatcher, state)
      effect.sink { input in
        output.dispatch(input)
      }
      .store(in: &_cancellationEffectCancellables)
    }
    return io
  }
}
