import Combine
import Foundation

#if compiler(>=5.7)
public class EffectMiddleware<State, Action>: MiddlewareProtocol {

  private var cancellables = Set<AnyCancellable>()

  @usableFromInline
  let handle: (Action, ActionSource, @escaping GetState<State>) -> EffectTask<Action>

  @usableFromInline
  init(
    internal handle: @escaping (Action, ActionSource, @escaping GetState<State>) -> EffectTask<Action>
  ) {
    self.handle = handle
  }

  @inlinable
  public convenience init(_ handle: @escaping (Action, ActionSource, @escaping GetState<State>) -> EffectTask<Action>) {
    self.init(internal: handle)
  }

  public func handle(action: Action, from dispatcher: ActionSource, state: @escaping GetState<State>) -> IO<Action> {
    let io = IO<Action> { [weak self] output in
      guard let self else { return }
      let effect = self.handle(action, dispatcher, state)
      effect.sink { input in
        output.dispatch(input)
      }
      .store(in: &self.cancellables)
    }
    return io
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
