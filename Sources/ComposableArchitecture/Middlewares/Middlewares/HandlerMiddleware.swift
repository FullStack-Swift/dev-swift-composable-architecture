import Foundation

// MARK: ActionHandlerMiddleware
public struct ActionHandlerMiddleware<State, Action>: MiddlewareProtocol {
  @usableFromInline
  let handle: (State, Action, ActionSource, AnyActionHandler<Action>) -> Void

  @usableFromInline
  init(
    internal handle: @escaping (State, Action, ActionSource, AnyActionHandler<Action>) -> Void
  ) {
    self.handle = handle
  }

  @inlinable
  public init(_ handle: @escaping (State, Action, ActionSource, AnyActionHandler<Action>) -> Void) {
    self.init(internal: handle)
  }


  @inlinable
  public func handle( state: State, action: Action, from dispatcher: ActionSource) -> IO<Action> {
    IO<Action>.init { actionHandler in
      self.handle(state, action, dispatcher, actionHandler)
    }
  }
}

// MARK: AsyncActionHandlerMiddleware
public struct AsyncActionHandlerMiddleware<State, Action>: MiddlewareProtocol {
  @usableFromInline
  let handle: (State, Action, ActionSource, AsyncAnyActionHandler<Action>) async throws -> ()

  @usableFromInline
  init(
    internal handle: @escaping (State, Action, ActionSource, AsyncAnyActionHandler<Action>) async throws -> ()
  ) {
    self.handle = handle
  }

  @inlinable
  public init(_ handle: @escaping (State, Action, ActionSource, AsyncAnyActionHandler<Action>) async throws -> ()) {
    self.init(internal: handle)
  }

  public func handle(state: State, action: Action, from dispatcher: ActionSource) -> IO<Action> {
    let io = IO<Action> { actionHandler in
      Task { @MainActor in
        try await handle(state, action, dispatcher, actionHandler.toAsyncAnyActionHandler())
      }
    }
    return io
  }
}
