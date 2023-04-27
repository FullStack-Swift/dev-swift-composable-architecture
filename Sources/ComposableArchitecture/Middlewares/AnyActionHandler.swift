public struct AnyActionHandler<ActionType>: ActionHandler, @unchecked Sendable {
  private let realHandler: (DispatchedAction<ActionType>) -> Void

  public init<A: ActionHandler>(_ realHandler: A) where A.ActionType == ActionType {
    self.init(realHandler.dispatch)
  }

  public init(_ realHandler: @escaping (DispatchedAction<ActionType>) -> Void) {
    self.realHandler = realHandler
  }

  public func dispatch(_ dispatchedAction: DispatchedAction<ActionType>) {
    realHandler(dispatchedAction)
  }
}

extension ActionHandler {
  public func eraseToAnyActionHandler() -> AnyActionHandler<ActionType> {
    AnyActionHandler(self)
  }
}
