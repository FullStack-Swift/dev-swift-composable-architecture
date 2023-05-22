import Foundation

extension MiddlewareProtocol {
  
  func debug(_ prefix: String = "") -> any MiddlewareProtocol {
    return self <> AnyMiddlewareDebug(prefix)
  }
}

struct AnyMiddlewareDebug<State, Action>: MiddlewareProtocol {

  let prefix: String

  init(_ prefix: String) {
    self.prefix = prefix
  }

  func handle(state: State, action: Action, from dispatcher: ActionSource) -> IO<Action> {
#if DEBUG
    print(prefix, state, action, dispatcher)
    return .none
#else
    return .none
#endif
  }
  
}
