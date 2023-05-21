import Foundation

extension MiddlewareProtocol {
  
  func debug() -> any MiddlewareProtocol {
    return self <> AnyMiddlewareDebug()
  }
}

struct AnyMiddlewareDebug<State, Action>: MiddlewareProtocol {

  func handle(action: Action, from dispatcher: ActionSource, state: State) -> IO<Action> {
#if DEBUG
    print(state, dispatcher, action)
    return .none
#else
    return .none
#endif
  }
  
}
