/// Combines multiple reducers into a single reducer.
///
/// `CombineMiddlewares` takes a block that can combine a number of reducers using a
/// ``MiddlewareBuilder``.
///
/// Useful for grouping reducers together and applying reducer modifiers to the result.
///
/// ```swift
/// var body: some ReducerProtocol<State, Action> {
///   CombineReducers {
///     ReducerA()
///     ReducerB()
///     ReducerC()
///   }
///   .ifLet(\.child, action: /Action.child)
/// }
/// ```
public struct CombineMiddlewares<State, Action, Middlewares: MiddlewareProtocol>: MiddlewareProtocol
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
  
  public func handle(action: Action, from dispatcher: ActionSource, state: State) -> IO<Action> {
    self.middlewares.handle(action: action, from: dispatcher, state: state)
  }
}
