public struct AsyncAnyActionHandler<ActionType>: AsyncActionHandler {
  private let realHandler: (DispatchedAction<ActionType>) async -> Void
  
  public init<A: ActionHandler>(_ realHandler: A) where A.ActionType == ActionType {
    self.init(realHandler.dispatch)
  }
  
  public init(_ realHandler: @escaping (DispatchedAction<ActionType>) async -> Void) {
    self.realHandler = realHandler
  }
  
  public func dispatch(_ dispatchedAction: DispatchedAction<ActionType>) async {
    await realHandler(dispatchedAction)
  }
}
