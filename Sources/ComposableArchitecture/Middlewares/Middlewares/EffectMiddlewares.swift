import Combine
import Foundation

public struct EffectMiddleware<State, Action>: Middleware {

  @usableFromInline
  let handle: (State, Action, ActionSource) -> Effect<Action>

  @usableFromInline
  init(
    internal handle: @escaping (State, Action, ActionSource) -> Effect<Action>
  ) {
    self.handle = handle
  }

  @inlinable
  public init(_ handle: @escaping (State, Action, ActionSource) -> Effect<Action>) {
    self.init(internal: handle)
  }

  public func handle(state: State, action: Action, from dispatcher: ActionSource) -> IO<Action> {
    let io = IO<Action> { output in
      let effect = self.handle(state, action, dispatcher)
      Task { @MainActor in
        for await action in effect.actions {
          output.dispatch(action)
        }
      }
    }
    return io
  }
}
