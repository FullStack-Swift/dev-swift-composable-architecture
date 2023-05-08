#if compiler(>=5.7)
public struct IdentityMiddleware<State, Action>: MiddlewareProtocol, Equatable {

    public init() { }

    public func handle(
        action: Action,
        from dispatcher: ActionSource,
        state: @escaping GetState<State>
    ) -> IO<Action> {
        .pure()
    }
}

#else
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

#endif
