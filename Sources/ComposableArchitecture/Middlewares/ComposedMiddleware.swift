#if compiler(>=5.7)
public struct ComposedMiddleware<State, Action>: MiddlewareProtocol {
  var middlewares: [AnyMiddleware<State, Action>] = []

  public init(middlewares: [AnyMiddleware<State, Action>] = []) {
    self.middlewares = middlewares
  }

  public mutating func append<M: MiddlewareProtocol>(middleware: M) where M.State == State, M.Action == Action {
    if middleware is IdentityMiddleware<State, Action> { return }
    if (middleware as? AnyMiddleware<State, Action>)?.isIdentity == true { return }
    if let composedAlready = middleware as? ComposedMiddleware<State, Action> {
      middlewares.append(contentsOf: composedAlready.middlewares)
      return
    }
    if let composedAlready = (middleware as? AnyMiddleware<State, Action>)?.isComposed {
      middlewares.append(contentsOf: composedAlready.middlewares)
      return
    }
    middlewares.append(middleware.eraseToAnyMiddleware())
  }

  public func handle(action: Action, from dispatcher: ActionSource, state: @escaping GetState<State>) -> IO<Action> {
    middlewares.reduce(into: IO<Action>.pure()) { effects, middleware in
      effects = middleware.handle(action: action, from: dispatcher, state: state) <> effects
    }
  }
}

public func <> <M1: MiddlewareProtocol, M2: MiddlewareProtocol>(lhs: M1, rhs: M2) -> ComposedMiddleware<M1.State, M1.Action> where M1.State == M2.State, M1.Action == M2.Action {
  var container = lhs as? ComposedMiddleware<M1.State, M1.Action> ?? (lhs as? AnyMiddleware<M1.State, M1.Action>)?.isComposed ?? {
    var newContainer: ComposedMiddleware<M1.State, M1.Action> = .init()
    newContainer.append(middleware: lhs)
    return newContainer
  }()
  container.append(middleware: rhs)
  return container
}

extension ComposedMiddleware {
  public static var identity: ComposedMiddleware<State, Action> {
    .init()
  }
}

#else
public struct ComposedMiddleware<InputActionType, OutputActionType, StateType>: MiddlewareProtocol {
  var middlewares: [AnyMiddleware<InputActionType, OutputActionType, StateType>] = []

  public init(middlewares: [AnyMiddleware<InputActionType, OutputActionType, StateType>] = []) {
    self.middlewares = middlewares
  }

  public mutating func append<M: MiddlewareProtocol>(middleware: M)
  where M.InputActionType == InputActionType,
        M.OutputActionType == OutputActionType,
        M.StateType == StateType {
          if middleware is IdentityMiddleware<InputActionType, OutputActionType, StateType> { return }

          if (middleware as? AnyMiddleware<InputActionType, OutputActionType, StateType>)?.isIdentity == true { return }

          if let composedAlready = middleware as? ComposedMiddleware<InputActionType, OutputActionType, StateType> {
            middlewares.append(contentsOf: composedAlready.middlewares)
            return
          }

          if let composedAlready = (middleware as? AnyMiddleware<InputActionType, OutputActionType, StateType>)?.isComposed {
            middlewares.append(contentsOf: composedAlready.middlewares)
            return
          }

          middlewares.append(middleware.eraseToAnyMiddleware())
        }

  public func handle(action: InputActionType, from dispatcher: ActionSource, state: @escaping GetState<StateType>) -> IO<OutputActionType> {
    middlewares.reduce(into: IO<OutputActionType>.pure()) { effects, middleware in
      effects = middleware.handle(action: action, from: dispatcher, state: state) <> effects
    }
  }
}

public func <> <M1: MiddlewareProtocol, M2: MiddlewareProtocol>(lhs: M1, rhs: M2)
-> ComposedMiddleware<M1.InputActionType, M1.OutputActionType, M1.StateType>
where M1.InputActionType == M2.InputActionType,
M1.OutputActionType == M2.OutputActionType,
M1.StateType == M2.StateType {
  var container =
  lhs as? ComposedMiddleware<M1.InputActionType, M1.OutputActionType, M1.StateType>
  ?? (lhs as? AnyMiddleware<M1.InputActionType, M1.OutputActionType, M1.StateType>)?.isComposed
  ?? {
    var newContainer: ComposedMiddleware<M1.InputActionType, M1.OutputActionType, M1.StateType> = .init()
    newContainer.append(middleware: lhs)
    return newContainer
  }()

  container.append(middleware: rhs)
  return container
}

extension ComposedMiddleware {
  public static var identity: ComposedMiddleware<InputActionType, OutputActionType, StateType> {
    .init()
  }
}

#endif
