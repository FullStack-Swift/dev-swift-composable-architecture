public protocol ActionHandler {
  
  associatedtype ActionType
  
  func dispatch(_ dispatchedAction: DispatchedAction<ActionType>)
}

extension ActionHandler {
  public func dispatch(_ action: ActionType, file: String = #file, function: String = #function, line: UInt = #line, info: String? = nil) {
    self.dispatch(action, from: .init(file: file, function: function, line: line, info: info))
  }

  public func dispatch(_ action: ActionType, from dispatcher: ActionSource) {
    self.dispatch(DispatchedAction(action, dispatcher: dispatcher))
  }
}

extension ActionHandler {
  public func contramap<NewActionType>(_ transform: @escaping (NewActionType) -> ActionType) -> AnyActionHandler<NewActionType> {
    AnyActionHandler { dispatchedAction in
      self.dispatch(dispatchedAction.map(transform))
    }
  }
}
