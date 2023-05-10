import Foundation

public protocol AsyncActionHandler {
  
  associatedtype Action

  func dispatch(_ dispatchedAction: DispatchedAction<Action>) async throws
}

extension AsyncActionHandler {
  public func dispatch(_ action: Action, file: String = #file, function: String = #function, line: UInt = #line, info: String? = nil) async throws {
    try await self.dispatch(action, from: .init(file: file, function: function, line: line, info: info))
  }

  public func dispatch(_ action: Action, from dispatcher: ActionSource) async throws {
    try await self.dispatch(DispatchedAction(action, dispatcher: dispatcher))
  }
}

extension AsyncActionHandler {
  public func map<NewAction>(_ transform: @escaping(NewAction) -> Action) -> AsyncAnyActionHandler<NewAction> {
    AsyncAnyActionHandler { dispatchedAction in
      try await self.dispatch(dispatchedAction.map(transform))
    }
  }
}
