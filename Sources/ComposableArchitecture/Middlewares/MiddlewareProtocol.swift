public protocol MiddlewareProtocol {
  
  associatedtype InputActionType
  
  associatedtype OutputActionType
  
  associatedtype StateType
  
  func handle(
    action: InputActionType,
    from dispatcher: ActionSource,
    state: @escaping GetState<StateType>
  ) -> IO<OutputActionType>
}
