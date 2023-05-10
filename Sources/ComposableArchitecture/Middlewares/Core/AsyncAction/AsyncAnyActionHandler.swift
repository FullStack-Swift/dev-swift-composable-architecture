import Foundation

public struct AsyncAnyActionHandler<Action>: AsyncActionHandler {
  private let realHandler: (DispatchedAction<Action>) async throws -> Void
  
  public init<A: AsyncActionHandler>(_ realHandler: A) where A.Action == Action {
    self.init(realHandler.asyncDispatch)
  }
  
  public init(_ realHandler: @escaping (DispatchedAction<Action>) async throws -> Void) {
    self.realHandler = realHandler
  }
  
  public func asyncDispatch(_ dispatchedAction: DispatchedAction<Action>) async throws {
    try await realHandler(dispatchedAction)
  }
}

extension AsyncActionHandler {
  public func eraseToAsyncAnyActionHandler() -> AsyncAnyActionHandler<Action> {
    AsyncAnyActionHandler(self)
  }
}

extension AsyncAnyActionHandler {
  func toAnyActionHandler() -> AnyActionHandler<Action> {
    AnyActionHandler.init { dispatchedAction in
      Task {
        try await asyncDispatch(dispatchedAction)
      }
    }
  }
}
