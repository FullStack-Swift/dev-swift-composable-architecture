/// A result builder for combining middlewares into a single middleware by running each, one after the
/// other, and returning their merged effects.
///
/// It is most common to encounter a reducer builder context when conforming a type to
/// ``MiddlewareProtocol`` and implementing its ``MiddlewareProtocol/body-swift.property-97ymy`` property.
///
/// See ``CombineMiddlewares`` for an entry point into a reducer builder context.
@resultBuilder
public enum MiddlewareBuilder<State, Action> {
  @inlinable
  public static func buildArray<M: Middleware>(_ middlewares: [M]) -> _SequenceMany<M>
  where M.State == State, M.Action == Action {
    _SequenceMany(middlewares: middlewares)
  }

  @inlinable
  public static func buildBlock() -> EmptyMiddleware<State, Action> {
    EmptyMiddleware()
  }

  @inlinable
  public static func buildBlock<M: Middleware>(_ middleware: M) -> M
  where M.State == State, M.Action == Action {
    middleware
  }

  @inlinable
  public static func buildEither<M0: Middleware, M1: Middleware>(
    first reducer: M0
  ) -> _Conditional<M0, M1>
  where M0.State == State, M0.Action == Action, M1.State == State, M1.Action == Action {
    .first(reducer)
  }

  @inlinable
  public static func buildEither<M0: Middleware, M1: Middleware>(
    second reducer: M1
  ) -> _Conditional<M0, M1>
  where M0.State == State, M0.Action == Action, M1.State == State, M1.Action == Action {
    .second(reducer)
  }

  @inlinable
  public static func buildExpression<M: Middleware>(_ expression: M) -> M
  where M.State == State, M.Action == Action {
    expression
  }

  @inlinable
  public static func buildFinalResult<M: Middleware>(_ reducer: M) -> M
  where M.State == State, M.Action == Action {
    reducer
  }

  @inlinable
  public static func buildLimitedAvailability<M: Middleware>(
    _ wrapped: M
  ) -> IOMiddleware<State, Action>
  where M.State == State, M.Action == Action {
    IOMiddleware(wrapped)
  }

  @inlinable
  public static func buildOptional<M: Middleware>(_ wrapped: M?) -> M?
  where M.State == State, M.Action == Action {
    wrapped
  }

  @inlinable
  public static func buildPartialBlock<M: Middleware>(
    first: M
  ) -> M
  where M.State == State, M.Action == Action {
    first
  }

  @inlinable
  public static func buildPartialBlock<M0: Middleware, M1: Middleware>(
    accumulated: M0, next: M1
  ) -> _Sequence<M0, M1>
  where M0.State == State, M0.Action == Action, M1.State == State, M1.Action == Action {
    _Sequence(accumulated, next)
  }

  public enum _Conditional<First: Middleware, Second: Middleware>: Middleware
  where
  First.State == Second.State,
  First.Action == Second.Action
  {
  case first(First)
  case second(Second)

    @inlinable
    public func handle( state: First.State, action: First.Action, from dispatcher: ActionSource) -> IO<First.Action> {
      switch self {
        case let .first(first):
          return first.handle(state: state, action: action, from: dispatcher)
        case let .second(second):
          return second.handle(state: state, action: action, from: dispatcher)
      }
    }
  }

  public struct _Sequence<M0: Middleware, M1: Middleware>: Middleware
  where M0.State == M1.State, M0.Action == M1.Action {
    @usableFromInline
    let m0: M0

    @usableFromInline
    let m1: M1

    @usableFromInline
    init(_ m0: M0, _ m1: M1) {
      self.m0 = m0
      self.m1 = m1
    }

    @inlinable
    public func handle(state: M0.State, action: M0.Action, from dispatcher: ActionSource) -> IO<M0.Action> {
      self.m0.handle(state: state, action: action, from: dispatcher)
      <> self.m1.handle(state: state, action: action, from: dispatcher)
    }
  }

  public struct _SequenceMany<Element: Middleware>: Middleware {
    @usableFromInline
    let middlewares: [Element]

    @usableFromInline
    init(middlewares: [Element]) {
      self.middlewares = middlewares
    }

    @inlinable
    public func handle(state: Element.State, action: Element.Action, from dispatcher: ActionSource) -> IO<Element.Action> {
      self.middlewares.reduce(into: IO<Action>.none) {
        $0 = $1.handle(state: state, action: action, from: dispatcher) <> $0
      }
    }
  }
}
