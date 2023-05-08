import Combine
import Foundation

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
      let effect = self.effect(action: action, state: state)
      effect.sink { inputAction in
        output.dispatch(inputAction)
      }
      .store(in: &self.cancellables)
    }
    return io
  }


  open func effect(
    action: InputActionType,
    state: @escaping GetState<StateType>
  ) -> EffectTask<OutputActionType> {
    return EffectTask(operation: .none)
  }
}

