import Foundation

public struct AsyncAnyActionHandler<Action>: AsyncActionHandler {
  private let realHandler: (DispatchedAction<Action>) async -> Void
  
  public init<A: AsyncActionHandler>(_ realHandler: A) where A.Action == Action {
    self.init(realHandler.dispatch)
  }
  
  public init(_ realHandler: @escaping (DispatchedAction<Action>) async -> Void) {
    self.realHandler = realHandler
  }
  
  public func dispatch(_ dispatchedAction: DispatchedAction<Action>) async {
    await realHandler(dispatchedAction)
  }
}

extension AsyncActionHandler {
  public func eraseToAsyncAnyActionHandler() -> AsyncAnyActionHandler<Action> {
    AsyncAnyActionHandler(self)
  }
}
