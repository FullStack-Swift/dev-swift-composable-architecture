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
  public static func buildArray<M: MiddlewareProtocol>(_ middlewares: [M]) -> _SequenceMany<M>
  where M.State == State, M.Action == Action {
    _SequenceMany(middlewares: middlewares)
  }

  @inlinable
  public static func buildBlock() -> EmptyMiddleware<State, Action> {
    EmptyMiddleware()
  }

  @inlinable
  public static func buildBlock<M: MiddlewareProtocol>(_ middleware: M) -> M
  where M.State == State, M.Action == Action {
    middleware
  }

  @inlinable
  public static func buildEither<M0: MiddlewareProtocol, M1: MiddlewareProtocol>(
    first reducer: M0
  ) -> _Conditional<M0, M1>
  where M0.State == State, M0.Action == Action, M1.State == State, M1.Action == Action {
    .first(reducer)
  }

  @inlinable
  public static func buildEither<M0: MiddlewareProtocol, M1: MiddlewareProtocol>(
    second reducer: M1
  ) -> _Conditional<M0, M1>
  where M0.State == State, M0.Action == Action, M1.State == State, M1.Action == Action {
    .second(reducer)
  }

  @inlinable
  public static func buildExpression<M: MiddlewareProtocol>(_ expression: M) -> M
  where M.State == State, M.Action == Action {
    expression
  }

  @inlinable
  public static func buildFinalResult<M: MiddlewareProtocol>(_ reducer: M) -> M
  where M.State == State, M.Action == Action {
    reducer
  }

  @inlinable
  public static func buildLimitedAvailability<M: MiddlewareProtocol>(
    _ wrapped: M
  ) -> Middleware<State, Action>
  where M.State == State, M.Action == Action {
    Middleware(wrapped)
  }

  @inlinable
  public static func buildOptional<M: MiddlewareProtocol>(_ wrapped: M?) -> M?
  where M.State == State, M.Action == Action {
    wrapped
  }

  @inlinable
  public static func buildPartialBlock<M: MiddlewareProtocol>(
    first: M
  ) -> M
  where M.State == State, M.Action == Action {
    first
  }

  @inlinable
  public static func buildPartialBlock<M0: MiddlewareProtocol, M1: MiddlewareProtocol>(
    accumulated: M0, next: M1
  ) -> _Sequence<M0, M1>
  where M0.State == State, M0.Action == Action, M1.State == State, M1.Action == Action {
    _Sequence(accumulated, next)
  }

#if swift(<5.7)
  @inlinable
  public static func buildBlock<
    R0: MiddlewareProtocol,
    R1: MiddlewareProtocol
  >(
    _ r0: R0,
    _ r1: R1
  ) -> _Sequence<R0, R1>
  where R0.State == State, R0.Action == Action {
    _Sequence(r0, r1)
  }

  @inlinable
  public static func buildBlock<
    R0: MiddlewareProtocol,
    R1: MiddlewareProtocol,
    R2: MiddlewareProtocol
  >(
    _ r0: R0,
    _ r1: R1,
    _ r2: R2
  ) -> _Sequence<_Sequence<R0, R1>, R2>
  where R0.State == State, R0.Action == Action {
    _Sequence(_Sequence(r0, r1), r2)
  }

  @inlinable
  public static func buildBlock<
    R0: MiddlewareProtocol,
    R1: MiddlewareProtocol,
    R2: MiddlewareProtocol,
    R3: MiddlewareProtocol
  >(
    _ r0: R0,
    _ r1: R1,
    _ r2: R2,
    _ r3: R3
  ) -> _Sequence<_Sequence<_Sequence<R0, R1>, R2>, R3>
  where R0.State == State, R0.Action == Action {
    _Sequence(_Sequence(_Sequence(r0, r1), r2), r3)
  }

  @inlinable
  public static func buildBlock<
    R0: MiddlewareProtocol,
    R1: MiddlewareProtocol,
    R2: MiddlewareProtocol,
    R3: MiddlewareProtocol,
    R4: MiddlewareProtocol
  >(
    _ r0: R0,
    _ r1: R1,
    _ r2: R2,
    _ r3: R3,
    _ r4: R4
  ) -> _Sequence<_Sequence<_Sequence<_Sequence<R0, R1>, R2>, R3>, R4>
  where R0.State == State, R0.Action == Action {
    _Sequence(_Sequence(_Sequence(_Sequence(r0, r1), r2), r3), r4)
  }

  @inlinable
  public static func buildBlock<
    R0: MiddlewareProtocol,
    R1: MiddlewareProtocol,
    R2: MiddlewareProtocol,
    R3: MiddlewareProtocol,
    R4: MiddlewareProtocol,
    R5: MiddlewareProtocol
  >(
    _ r0: R0,
    _ r1: R1,
    _ r2: R2,
    _ r3: R3,
    _ r4: R4,
    _ r5: R5
  ) -> _Sequence<_Sequence<_Sequence<_Sequence<_Sequence<R0, R1>, R2>, R3>, R4>, R5>
  where R0.State == State, R0.Action == Action {
    _Sequence(_Sequence(_Sequence(_Sequence(_Sequence(r0, r1), r2), r3), r4), r5)
  }

  @inlinable
  public static func buildBlock<
    R0: MiddlewareProtocol,
    R1: MiddlewareProtocol,
    R2: MiddlewareProtocol,
    R3: MiddlewareProtocol,
    R4: MiddlewareProtocol,
    R5: MiddlewareProtocol,
    R6: MiddlewareProtocol
  >(
    _ r0: R0,
    _ r1: R1,
    _ r2: R2,
    _ r3: R3,
    _ r4: R4,
    _ r5: R5,
    _ r6: R6
  ) -> _Sequence<
    _Sequence<_Sequence<_Sequence<_Sequence<_Sequence<R0, R1>, R2>, R3>, R4>, R5>, R6
  >
  where R0.State == State, R0.Action == Action {
    _Sequence(_Sequence(_Sequence(_Sequence(_Sequence(_Sequence(r0, r1), r2), r3), r4), r5), r6)
  }

  @inlinable
  public static func buildBlock<
    R0: MiddlewareProtocol,
    R1: MiddlewareProtocol,
    R2: MiddlewareProtocol,
    R3: MiddlewareProtocol,
    R4: MiddlewareProtocol,
    R5: MiddlewareProtocol,
    R6: MiddlewareProtocol,
    R7: MiddlewareProtocol
  >(
    _ r0: R0,
    _ r1: R1,
    _ r2: R2,
    _ r3: R3,
    _ r4: R4,
    _ r5: R5,
    _ r6: R6,
    _ r7: R7
  ) -> _Sequence<
    _Sequence<_Sequence<_Sequence<_Sequence<_Sequence<_Sequence<R0, R1>, R2>, R3>, R4>, R5>, R6>,
    R7
  >
  where R0.State == State, R0.Action == Action {
    _Sequence(
      _Sequence(
        _Sequence(_Sequence(_Sequence(_Sequence(_Sequence(r0, r1), r2), r3), r4), r5), r6
      ),
      r7
    )
  }

  @inlinable
  public static func buildBlock<
    R0: MiddlewareProtocol,
    R1: MiddlewareProtocol,
    R2: MiddlewareProtocol,
    R3: MiddlewareProtocol,
    R4: MiddlewareProtocol,
    R5: MiddlewareProtocol,
    R6: MiddlewareProtocol,
    R7: MiddlewareProtocol,
    R8: MiddlewareProtocol
  >(
    _ r0: R0,
    _ r1: R1,
    _ r2: R2,
    _ r3: R3,
    _ r4: R4,
    _ r5: R5,
    _ r6: R6,
    _ r7: R7,
    _ r8: R8
  ) -> _Sequence<
    _Sequence<
      _Sequence<
        _Sequence<_Sequence<_Sequence<_Sequence<_Sequence<R0, R1>, R2>, R3>, R4>, R5>, R6
      >,
      R7
    >,
    R8
  >
  where R0.State == State, R0.Action == Action {
    _Sequence(
      _Sequence(
        _Sequence(
          _Sequence(_Sequence(_Sequence(_Sequence(_Sequence(r0, r1), r2), r3), r4), r5), r6
        ),
        r7
      ),
      r8
    )
  }

  @inlinable
  public static func buildBlock<
    R0: MiddlewareProtocol,
    R1: MiddlewareProtocol,
    R2: MiddlewareProtocol,
    R3: MiddlewareProtocol,
    R4: MiddlewareProtocol,
    R5: MiddlewareProtocol,
    R6: MiddlewareProtocol,
    R7: MiddlewareProtocol,
    R8: MiddlewareProtocol,
    R9: MiddlewareProtocol
  >(
    _ r0: R0,
    _ r1: R1,
    _ r2: R2,
    _ r3: R3,
    _ r4: R4,
    _ r5: R5,
    _ r6: R6,
    _ r7: R7,
    _ r8: R8,
    _ r9: R9
  ) -> _Sequence<
    _Sequence<
      _Sequence<
        _Sequence<
          _Sequence<_Sequence<_Sequence<_Sequence<_Sequence<R0, R1>, R2>, R3>, R4>, R5>, R6
        >,
        R7
      >,
      R8
    >,
    R9
  >
  where R0.State == State, R0.Action == Action {
    _Sequence(
      _Sequence(
        _Sequence(
          _Sequence(
            _Sequence(_Sequence(_Sequence(_Sequence(_Sequence(r0, r1), r2), r3), r4), r5), r6
          ),
          r7
        ),
        r8
      ),
      r9
    )
  }

  @_disfavoredOverload
  @inlinable
  public static func buildFinalResult<M: MiddlewareProtocol>(_ middleware: M) -> Middleware<State, Action>
  where M.State == State, M.Action == Action {
    Middleware(middleware)
  }
#endif

  public enum _Conditional<First: MiddlewareProtocol, Second: MiddlewareProtocol>: MiddlewareProtocol
  where
  First.State == Second.State,
  First.Action == Second.Action
  {
  case first(First)
  case second(Second)

    @inlinable
    public func handle(action: First.Action, from dispatcher: ActionSource, state: First.State) -> IO<First.Action> {
      switch self {
        case let .first(first):
          return first.handle(action: action, from: dispatcher, state: state)
        case let .second(second):
          return second.handle(action: action, from: dispatcher, state: state)
      }
    }
  }

  public struct _Sequence<M0: MiddlewareProtocol, M1: MiddlewareProtocol>: MiddlewareProtocol
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
    public func handle(action: M0.Action, from dispatcher: ActionSource, state: M0.State) -> IO<M0.Action> {
      self.m0.handle(action: action, from: dispatcher, state: state)
      <> self.m1.handle(action: action, from: dispatcher, state: state)
    }
  }

  public struct _SequenceMany<Element: MiddlewareProtocol>: MiddlewareProtocol {
    @usableFromInline
    let middlewares: [Element]

    @usableFromInline
    init(middlewares: [Element]) {
      self.middlewares = middlewares
    }

    @inlinable
    public func handle(action: Element.Action, from dispatcher: ActionSource, state: Element.State) -> IO<Element.Action> {
      self.middlewares.reduce(into: IO<Action>.none()) {
        $0 = $1.handle(action: action, from: dispatcher, state: state) <> $0
      }
    }
  }
}
