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
  public func contramap<NewActionType>(_ transform: @escaping (NewActionType) -> Action) -> AnyActionHandler<NewActionType> {
    AnyActionHandler { dispatchedAction in
      self.dispatch(dispatchedAction.map(transform))
    }
  }
}
