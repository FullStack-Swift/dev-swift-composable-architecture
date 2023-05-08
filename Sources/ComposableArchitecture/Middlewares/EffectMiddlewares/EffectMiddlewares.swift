import Combine
import Foundation

#if compiler(>=5.7)

open class EffectMiddleware<State, Action>: MiddlewareProtocol {

  public var cancellables = Set<AnyCancellable>()

  public init() {}

  open func handle(
    action: Action,
    from dispatcher: ActionSource,
    state: @escaping GetState<State>
  ) -> IO<Action> {
    let io = IO<Action> { [weak self] output in
      guard let self else { return }
      let effect = self.effectHandle(action: action, state: state)
      effect.sink { inputAction in
        output.dispatch(inputAction)
      }
      .store(in: &self.cancellables)
    }
    return io
  }


  open func effectHandle(
    action: Action,
    state: @escaping GetState<State>
  ) -> EffectTask<Action> {
    return EffectTask(operation: .none)
  }
}

#else

open class EffectMiddleware<InputActionType, OutputActionType, StateType>: MiddlewareProtocol {

  public var cancellables = Set<AnyCancellable>()

  public init() {}

  open func handle(
    action: InputActionType,
    from dispatcher: ActionSource,
    state: @escaping GetState<StateType>
  ) -> IO<OutputActionType> {
    let io = IO<OutputActionType> { [weak self] output in
      guard let self else { return }
      let effect = self.effectHandle(action: action, state: state)
      effect.sink { inputAction in
        output.dispatch(inputAction)
      }
      .store(in: &self.cancellables)
    }
    return io
  }


  open func effectHandle(
    action: InputActionType,
    state: @escaping GetState<StateType>
  ) -> EffectTask<OutputActionType> {
    return EffectTask(operation: .none)
  }
}

#endif
