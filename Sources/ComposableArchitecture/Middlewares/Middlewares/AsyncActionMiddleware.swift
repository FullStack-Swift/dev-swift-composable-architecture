import Foundation

public struct AsyncActionMiddleware<State, Action>: Middleware {
  @usableFromInline
  let handle: (State, Action, ActionSource) async throws -> Action?

  @usableFromInline
  init(
    internal handle: @escaping (State, Action, ActionSource) async throws -> Action?
  ) {
    self.handle = handle
  }

  @inlinable
  public init(_ handle: @escaping (State, Action, ActionSource) async throws -> Action?) {
    self.init(internal: handle)
  }

  public func handle(state: State, action: Action, from dispatcher: ActionSource) -> IO<Action> {
    let io = IO<Action> { output in
      Task { @MainActor in
        if let outputAction = try? await self.handle(state, action, dispatcher) {
          output.dispatch(outputAction)
        }
      }
    }
    return io
  }
}
