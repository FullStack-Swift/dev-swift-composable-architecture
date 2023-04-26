import Foundation


public struct AnyMiddleware<InputActionType, OutputActionType, StateType>: MiddlewareProtocol {
  private let _handle: (InputActionType, ActionSource, @escaping GetState<StateType>) -> IO<OutputActionType>

  let isIdentity: Bool
  let isComposed: ComposedMiddleware<InputActionType, OutputActionType, StateType>?

  public init(
    handle: @escaping (InputActionType, ActionSource, @escaping GetState<StateType>) -> IO<OutputActionType>
  ) {
    self.init(handle: handle, isIdentity: false)
  }

  private init(
    handle: @escaping (InputActionType, ActionSource, @escaping GetState<StateType>) -> IO<OutputActionType>,
    isIdentity: Bool
  ) {
    self._handle = handle
    self.isIdentity = isIdentity
    self.isComposed = nil
  }

  private init(
    composed: ComposedMiddleware<InputActionType, OutputActionType, StateType>
  ) {
    self._handle = composed.handle
    self.isIdentity = false
    self.isComposed = composed
  }

  public init<M: MiddlewareProtocol>(_ realMiddleware: M)
  where M.InputActionType == InputActionType, M.OutputActionType == OutputActionType, M.StateType == StateType {
    if let alreadyErased = realMiddleware as? AnyMiddleware<InputActionType, OutputActionType, StateType> {
      self = alreadyErased
      return
    }
    if let composed = realMiddleware as? ComposedMiddleware<InputActionType, OutputActionType, StateType> {
      self.init(composed: composed)
      return
    }
    let isIdentity = realMiddleware is IdentityMiddleware<InputActionType, OutputActionType, StateType>
    self.init(handle: realMiddleware.handle, isIdentity: isIdentity)
  }

  public func handle(action: InputActionType, from dispatcher: ActionSource, state: @escaping GetState<StateType>) -> IO<OutputActionType> {
    _handle(action, dispatcher, state)
  }
}

extension MiddlewareProtocol {
  public func eraseToAnyMiddleware() -> AnyMiddleware<InputActionType, OutputActionType, StateType> {
    AnyMiddleware(self)
  }
}

