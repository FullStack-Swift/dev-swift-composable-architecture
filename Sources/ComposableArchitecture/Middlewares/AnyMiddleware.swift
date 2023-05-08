import Foundation
#if compiler(>=5.7)

public struct AnyMiddleware<State, Action>: MiddlewareProtocol {

    private let _handle: (Action, ActionSource, @escaping GetState<State>) -> IO<Action>

    let isIdentity: Bool
    let isComposed: ComposedMiddleware<State, Action>?

    public init(
        handle: @escaping (Action, ActionSource, @escaping GetState<State>) -> IO<Action>
    ) {
        self.init(handle: handle, isIdentity: false)
    }

    private init(
        handle: @escaping (Action, ActionSource, @escaping GetState<State>) -> IO<Action>,
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
        let isIdentity = realMiddleware is IdentityMiddleware<State, Action>
        self.init(handle: realMiddleware.handle, isIdentity: isIdentity)
    }

    public func handle(action: Action, from dispatcher: ActionSource, state: @escaping GetState<State>) -> IO<Action> {
        _handle(action, dispatcher, state)
    }
}

extension MiddlewareProtocol {
    public func eraseToAnyMiddleware() -> AnyMiddleware<State, Action> {
        AnyMiddleware(self)
    }
}

#else
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
#endif
