import Foundation

extension Middleware {
  
  func debug(_ prefix: String = "") -> any Middleware {
    return self <> AnyMiddlewareDebug(prefix)
  }
}

struct AnyMiddlewareDebug<State, Action>: Middleware {

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
