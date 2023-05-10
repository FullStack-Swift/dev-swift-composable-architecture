import Foundation

// MARK: ActionHandlerMiddleware
public struct ActionHandlerMiddleware<State, Action>: MiddlewareProtocol {
  @usableFromInline
  let handle: (Action, ActionSource, State, AnyActionHandler<Action>) -> Void

  @usableFromInline
  init(
    internal handle: @escaping (Action, ActionSource, State, AnyActionHandler<Action>) -> Void
  ) {
    self.handle = handle
  }

  @inlinable
  public init(_ handle: @escaping (Action, ActionSource, State, AnyActionHandler<Action>) -> Void) {
    self.init(internal: handle)
  }


  @inlinable
  public func handle(action: Action, from dispatcher: ActionSource, state: State) -> IO<Action> {
    IO<Action>.init { actionHandler in
      self.handle(action, dispatcher, state, actionHandler)
    }
  }
}

// MARK: AsyncActionHandlerMiddleware
public struct AsyncActionHandlerMiddleware<State, Action>: MiddlewareProtocol {
  @usableFromInline
  let handle: (Action, ActionSource, State, AsyncAnyActionHandler<Action>) async throws -> ()

  @usableFromInline
  init(
    internal handle: @escaping (Action, ActionSource, State, AsyncAnyActionHandler<Action>) async throws -> ()
  ) {
    self.handle = handle
  }

  @inlinable
  public init(_ handle: @escaping (Action, ActionSource, State, AsyncAnyActionHandler<Action>) async throws -> ()) {
    self.init(internal: handle)
  }

  public func handle(action: Action, from dispatcher: ActionSource, state: State) -> IO<Action> {
    let io = IO<Action> { actionHandler in
      Task { @MainActor in
        try await handle(action, dispatcher, state, actionHandler.toAsyncAnyActionHandler())
      }
    }
    return io
  }
}
