import Foundation

public struct AnyMiddleware<State, Action>: Middleware {
  
  private let _handle: (State, Action, ActionSource) -> IO<Action>
  
  let isIdentity: Bool
  let isComposed: ComposedMiddleware<State, Action>?
  
  public init(
    handle: @escaping (State, Action, ActionSource) -> IO<Action>
  ) {
    self.init(handle: handle, isIdentity: false)
  }
  
  private init(
    handle: @escaping (State, Action, ActionSource) -> IO<Action>,
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
  
  public init<M: Middleware>(_ realMiddleware: M)
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
  
  public func handle(state: State, action: Action, from dispatcher: ActionSource) -> IO<Action> {
    _handle(state, action, dispatcher)
  }
}

extension Middleware {
  public func eraseToAnyMiddleware() -> AnyMiddleware<State, Action> {
    AnyMiddleware(self)
  }
}
