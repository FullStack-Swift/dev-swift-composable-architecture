
#if compiler(>=5.7)
public protocol MiddlewareProtocol<State, Action> {

    associatedtype State

    associatedtype Action

    func handle(
        action: Action,
        from dispatcher: ActionSource,
        state: @escaping GetState<State>
    ) -> IO<Action>
}

#else
public protocol MiddlewareProtocol {

    associatedtype InputActionType

    associatedtype OutputActionType

    associatedtype StateType

    func handle(
        action: InputActionType,
        from dispatcher: ActionSource,
        state: @escaping GetState<StateType>
    ) -> IO<OutputActionType>
}

#endif

// NB: This is available only in Swift 5.7.1 due to the following bug:
//     https://github.com/apple/swift/issues/60550
#if swift(>=5.7.1)
/// A convenience for constraining a ``ReducerProtocol`` conformance. Available only in Swift
/// 5.7.1.
///
/// This allows you to specify the `body` of a ``ReducerProtocol`` conformance like so:
///
/// ```swift
/// var body: some ReducerProtocolOf<Self> {
///   // ...
/// }
/// ```
///
/// …instead of the more verbose:
///
/// ```swift
/// var body: some ReducerProtocol<State, Action> {
///   // ...
/// }
/// ```

public typealias MiddlewareProtocolOf<R: ReducerProtocol> = MiddlewareProtocol<R.State, R.Action>
#endif
