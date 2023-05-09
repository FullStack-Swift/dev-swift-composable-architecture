/// A type-erased reducer that invokes the given `reduce` function.
///
/// ``Reduce`` is useful for injecting logic into a reducer tree without the overhead of introducing
/// a new type that conforms to ``ReducerProtocol``.
public struct Middleware<State, Action>: MiddlewareProtocol {
  @usableFromInline
  let handle: (Action, ActionSource, @escaping GetState<State>) -> IO<Action>

  @usableFromInline
  init(
    internal handle: @escaping (Action, ActionSource, @escaping GetState<State>) -> IO<Action>
  ) {
    self.handle = handle
  }

  /// Initializes a middleware with a `handle` function.
  ///
  /// - Parameter reduce: A function that is called when ``handle(action:from::state)`` is invoked.
  @inlinable
  public init(_ handle: @escaping (Action, ActionSource, @escaping GetState<State>) -> IO<Action>) {
    self.init(internal: handle)
  }

  /// Type-erases a middleware.
  ///
  /// - Parameter middleware: A middleware that is called when ``handle(action:from::state)`` is invoked.
  @inlinable
  public init<M: MiddlewareProtocol>(_ middleware: M)
  where M.State == State, M.Action == Action {
    self.init(internal: middleware.handle(action:from:state:))
  }

  @inlinable
  public func handle(action: Action, from dispatcher: ActionSource, state: @escaping GetState<State>) -> IO<Action> {
    self.handle(action, dispatcher, state)
  }
}
