/// A middleware that does nothing.
///
/// While not very useful on its own, `EmptyMiddleware` can be used as a placeholder in APIs that hold
/// middlewares.
import Foundation

public struct EmptyMiddleware<State, Action>: Middleware {
  /// Initializes a middleware that does nothing.
  @inlinable
  public init() {
    self.init(internal: ())
  }

  @usableFromInline
  init(internal: Void) {}

  @inlinable
  public func handle(state: State, action: Action, from dispatcher: ActionSource) -> IO<Action> {
    .none
  }
}
