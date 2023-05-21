import Foundation

public struct ComposedMiddleware<State, Action>: MiddlewareProtocol {
  var middlewares: [AnyMiddleware<State, Action>] = []

  public init(middlewares: [AnyMiddleware<State, Action>] = []) {
    self.middlewares = middlewares
  }

  public mutating func append<M: MiddlewareProtocol>(middleware: M) where M.State == State, M.Action == Action {
    if middleware is EmptyMiddleware<State, Action> { return }
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

  public func handle(action: Action, from dispatcher: ActionSource, state: State) -> IO<Action> {
    middlewares.reduce(into: IO<Action>.none) { effects, middleware in
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
  public static var none: ComposedMiddleware<State, Action> {
    .init()
  }
}
