import Foundation

// MARK: IOMiddleware
public struct IOMiddleware<State, Action>: MiddlewareProtocol {
  @usableFromInline
  let handle: (Action, ActionSource, State) -> IO<Action>

  @usableFromInline
  init(
    internal handle: @escaping (Action, ActionSource, State) -> IO<Action>
  ) {
    self.handle = handle
  }

  /// Initializes a middleware with a `handle` function.
  ///
  /// - Parameter reduce: A function that is called when ``handle(action:from:state)`` is invoked.
  @inlinable
  public init(_ handle: @escaping (Action, ActionSource, State) -> IO<Action>) {
    self.init(internal: handle)
  }

  /// Type-erases a middleware.
  ///
  /// - Parameter middleware: A middleware that is called when ``handle(action:from:state)`` is invoked.
  @inlinable
  public init<M: MiddlewareProtocol>(_ middleware: M)
  where M.State == State, M.Action == Action {
    self.init(internal: middleware.handle(action:from:state:))
  }

  @inlinable
  public func handle(action: Action, from dispatcher: ActionSource, state: State) -> IO<Action> {
    self.handle(action, dispatcher, state)
  }
}

// MARK: AsyncIOMiddleware
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
