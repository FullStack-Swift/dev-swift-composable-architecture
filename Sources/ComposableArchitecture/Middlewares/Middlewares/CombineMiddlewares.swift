/// Combine multiple middlewares into a single middleware.
///
///
///
///
///
public struct CombineMiddlewares<State, Action, Middlewares: MiddlewareProtocol>: MiddlewareProtocol where State == Middlewares.State, Action == Middlewares.Action {
  @usableFromInline
  let middlewares: Middlewares
  
  @inlinable
  init(
    @MiddlewareBuilder<State, Action> _ build: () -> Middlewares
  ) {
    self.init(internal: build())
  }
  
  @usableFromInline
  init(internal middlewares: Middlewares) {
    self.middlewares = middlewares
  }
  
  public func handle(action: Action, from dispatcher: ActionSource, state: State) -> IO<Action> {
    self.middlewares.handle(action: action, from: dispatcher, state: state)
  }
}
