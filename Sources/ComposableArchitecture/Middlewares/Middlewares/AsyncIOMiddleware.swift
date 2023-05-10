import Foundation

public struct AsyncIOMiddleware<State, Action>: MiddlewareProtocol {
  @usableFromInline
  let handle: (Action, ActionSource, State) async throws -> AsyncIO<Action>

  @usableFromInline
  init(
    internal handle: @escaping (Action, ActionSource, State) async throws -> AsyncIO<Action>
  ) {
    self.handle = handle
  }

  @inlinable
  public init(_ handle: @escaping (Action, ActionSource, State) async throws -> AsyncIO<Action>) {
    self.init(internal: handle)
  }

  public func handle(action: Action, from dispatcher: ActionSource, state: State) -> IO<Action> {
    let io = IO<Action> { output in
      Task { @MainActor in
        if let asyncIO = try? await handle(action, dispatcher, state) {
          try await asyncIO.run { action in
            output.dispatch(action)
          }
        }
      }
    }
    return io
  }
}

