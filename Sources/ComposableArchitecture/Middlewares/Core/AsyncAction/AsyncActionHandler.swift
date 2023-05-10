import Foundation

public protocol AsyncActionHandler {
  
  associatedtype Action

  func asyncDispatch(_ dispatchedAction: DispatchedAction<Action>) async throws
}

extension AsyncActionHandler {
  public func asyncDispatch(_ action: Action, file: String = #file, function: String = #function, line: UInt = #line, info: String? = nil) async throws {
    try await self.asyncDispatch(action, from: .init(file: file, function: function, line: line, info: info))
  }

  public func asyncDispatch(_ action: Action, from dispatcher: ActionSource) async throws {
    try await self.asyncDispatch(DispatchedAction(action, dispatcher: dispatcher))
  }
}

extension AsyncActionHandler {
  public func map<NewAction>(_ transform: @escaping(NewAction) -> Action) -> AsyncAnyActionHandler<NewAction> {
    AsyncAnyActionHandler { dispatchedAction in
      try await self.asyncDispatch(dispatchedAction.map(transform))
    }
  }
}

// MARK: Support Like ActionHandler
extension AsyncActionHandler {
  func dispatch(_ dispatchedAction: DispatchedAction<Action>) {
    Task {
      try await asyncDispatch(dispatchedAction)
    }
  }

  public func dispatch(_ action: Action, file: String = #file, function: String = #function, line: UInt = #line, info: String? = nil) {
    self.dispatch(action, from: .init(file: file, function: function, line: line, info: info))
  }

  public func dispatch(_ action: Action, from dispatcher: ActionSource) {
    self.dispatch(DispatchedAction(action, dispatcher: dispatcher))
  }
}
