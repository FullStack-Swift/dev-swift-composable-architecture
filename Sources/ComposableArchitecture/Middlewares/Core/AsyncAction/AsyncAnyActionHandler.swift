import Foundation

public struct AsyncAnyActionHandler<Action>: AsyncActionHandler {
  private let realHandler: (DispatchedAction<Action>) async throws -> Void
  
  public init<A: AsyncActionHandler>(_ realHandler: A) where A.Action == Action {
    self.init(realHandler.dispatch)
  }
  
  public init(_ realHandler: @escaping (DispatchedAction<Action>) async throws -> Void) {
    self.realHandler = realHandler
  }
  
  public func dispatch(_ dispatchedAction: DispatchedAction<Action>) async throws {
    try await realHandler(dispatchedAction)
  }
}

extension AsyncActionHandler {
  public func eraseToAsyncAnyActionHandler() -> AsyncAnyActionHandler<Action> {
    AsyncAnyActionHandler(self)
  }
}
