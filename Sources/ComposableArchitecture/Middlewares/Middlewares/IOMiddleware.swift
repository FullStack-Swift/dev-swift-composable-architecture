import Foundation

// MARK: IOMiddleware
public struct IOMiddleware<State, Action>: Middleware {
  @usableFromInline
  let handle: (State, Action, ActionSource) -> IO<Action>

  @usableFromInline
  init(
    internal handle: @escaping (State, Action, ActionSource) -> IO<Action>
  ) {
    self.handle = handle
  }

  /// Initializes a middleware with a `handle` function.
  ///
  /// - Parameter reduce: A function that is called when ``handle(action:from:state)`` is invoked.
  @inlinable
  public init(_ handle: @escaping (State, Action, ActionSource) -> IO<Action>) {
    self.init(internal: handle)
  }

  /// Type-erases a middleware.
  ///
  /// - Parameter middleware: A middleware that is called when ``handle(action:from:state)`` is invoked.
  @inlinable
  public init<M: Middleware>(_ middleware: M)
  where M.State == State, M.Action == Action {
    self.init(internal: middleware.handle(state:action:from:))
  }

  @inlinable
  public func handle(state: State, action: Action, from dispatcher: ActionSource) -> IO<Action> {
    self.handle(state, action, dispatcher)
  }
}

// MARK: AsyncIOMiddleware
public struct AsyncIOMiddleware<State, Action>: Middleware {
  @usableFromInline
  let handle: (State, Action, ActionSource) async throws -> AsyncIO<Action>

  @usableFromInline
  init(
    internal handle: @escaping (State, Action, ActionSource) async throws -> AsyncIO<Action>
  ) {
    self.handle = handle
  }

  @inlinable
  public init(_ handle: @escaping (State, Action, ActionSource) async throws -> AsyncIO<Action>) {
    self.init(internal: handle)
  }

  public func handle(state: State, action: Action, from dispatcher: ActionSource) -> IO<Action> {
    let io = IO<Action> { output in
      Task { @MainActor in
        if let asyncIO = try? await handle(state, action, dispatcher) {
          try await asyncIO.run { action in
            output.dispatch(action)
          }
        }
      }
    }
    return io
  }
}
