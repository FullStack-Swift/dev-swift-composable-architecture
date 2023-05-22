import Foundation

extension MiddlewareProtocol {
  
  func debug() -> any MiddlewareProtocol {
    return self <> AnyMiddlewareDebug()
  }
}

struct AnyMiddlewareDebug<State, Action>: MiddlewareProtocol {

  func handle(state: State, action: Action, from dispatcher: ActionSource) -> IO<Action> {
#if DEBUG
    print(state, dispatcher, action)
    return .none
#else
    return .none
#endif
  }
  
}
