import Foundation

public struct AnyMiddleware<State, Action>: MiddlewareProtocol {
  
  private let _handle: (Action, ActionSource, State) -> IO<Action>
  
  let isIdentity: Bool
  let isComposed: ComposedMiddleware<State, Action>?
  
  public init(
    handle: @escaping (Action, ActionSource, State) -> IO<Action>
  ) {
    self.init(handle: handle, isIdentity: false)
  }
  
  private init(
    handle: @escaping (Action, ActionSource, State) -> IO<Action>,
    isIdentity: Bool
  ) {
    self._handle = handle
    self.isIdentity = isIdentity
    self.isComposed = nil
  }
  
  private init(
    composed: ComposedMiddleware<State, Action>
  ) {
    self._handle = composed.handle
    self.isIdentity = false
    self.isComposed = composed
  }
  
  public init<M: MiddlewareProtocol>(_ realMiddleware: M)
  where M.State == State, M.Action == Action {
    if let alreadyErased = realMiddleware as? AnyMiddleware<State, Action> {
      self = alreadyErased
      return
    }
    if let composed = realMiddleware as? ComposedMiddleware<State, Action> {
      self.init(composed: composed)
      return
    }
    let isIdentity = realMiddleware is EmptyMiddleware<State, Action>
    self.init(handle: realMiddleware.handle, isIdentity: isIdentity)
  }
  
  public func handle(action: Action, from dispatcher: ActionSource, state: State) -> IO<Action> {
    _handle(action, dispatcher, state)
  }
}

extension MiddlewareProtocol {
  public func eraseToAnyMiddleware() -> AnyMiddleware<State, Action> {
    AnyMiddleware(self)
  }
}
