import _Concurrency
import Foundation

public struct AsyncMiddleware<State, Action>: MiddlewareProtocol {
  @usableFromInline
  let handle: (Action, ActionSource, State) async throws -> Action?

  @usableFromInline
  init(
    internal handle: @escaping (Action, ActionSource, State) async throws -> Action?
  ) {
    self.handle = handle
  }

  @inlinable
  public init(_ handle: @escaping (Action, ActionSource, State) async throws -> Action?) {
    self.init(internal: handle)
  }

  public func handle(action: Action, from dispatcher: ActionSource, state: State) -> IO<Action> {
    let io = IO<Action> { output in
      Task { @MainActor in
        if let outputAction = try? await self.handle(action, dispatcher, state) {
          output.dispatch(outputAction)
        }
      }
    }
    return io
  }
}

public struct OutputAsyncMiddleware<State, Action>: MiddlewareProtocol {
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
          Task { @MainActor in
            try await asyncIO.run { action in
              output.dispatch(action)
            }
          }
        }
      }
    }
    return io
  }
}
