public struct IdentityMiddleware<InputActionType, OutputActionType, StateType>: MiddlewareProtocol, Equatable {

  public init() { }

  public func handle(
    action: InputActionType,
    from dispatcher: ActionSource,
    state: @escaping GetState<StateType>
  ) -> IO<OutputActionType> {
    .pure()
  }
}

