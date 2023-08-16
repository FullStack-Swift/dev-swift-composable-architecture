/// Combines multiple reducers into a single reducer.
///
/// `CombineMiddlewares` takes a block that can combine a number of reducers using a
/// ``MiddlewareBuilder``.
public struct CombineMiddlewares<State, Action, Middlewares: Middleware>: Middleware
where State == Middlewares.State, Action == Middlewares.Action {
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
  
  public func handle(state: State, action: Action, from dispatcher: ActionSource) -> IO<Action> {
    self.middlewares.handle(state: state, action: action, from: dispatcher)
  }
}
