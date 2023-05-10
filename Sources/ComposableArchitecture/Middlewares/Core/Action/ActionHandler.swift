import Foundation

public protocol ActionHandler {
  
  associatedtype Action
  
  func dispatch(_ dispatchedAction: DispatchedAction<Action>)
}

extension ActionHandler {
  public func dispatch(_ action: Action, file: String = #file, function: String = #function, line: UInt = #line, info: String? = nil) {
    self.dispatch(action, from: .init(file: file, function: function, line: line, info: info))
  }

  public func dispatch(_ action: Action, from dispatcher: ActionSource) {
    self.dispatch(DispatchedAction(action, dispatcher: dispatcher))
  }
}

extension ActionHandler {
  public func map<NewActionType>(_ transform: @escaping (NewActionType) -> Action) -> AnyActionHandler<NewActionType> {
    AnyActionHandler { dispatchedAction in
      self.dispatch(dispatchedAction.map(transform))
    }
  }
}

// MARK: Support Like ActionHandler
extension ActionHandler {
  func asyncDispatch(_ dispatchedAction: DispatchedAction<Action>) async throws {
    dispatch(dispatchedAction)
  }
  public func asyncDispatch(_ action: Action, file: String = #file, function: String = #function, line: UInt = #line, info: String? = nil) async throws {
    try await self.asyncDispatch(action, from: .init(file: file, function: function, line: line, info: info))
  }

  public func asyncDispatch(_ action: Action, from dispatcher: ActionSource) async throws {
    try await self.asyncDispatch(DispatchedAction(action, dispatcher: dispatcher))
  }

}
