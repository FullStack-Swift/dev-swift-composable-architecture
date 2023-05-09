#if compiler(>=5.7)
/// A protocol that describes how to create effect of an application to render state,
/// given an action and describes new ``action``s should be excuted later by the store
///
///Confirm types to this protocol to respresent the domain, logic
///
public protocol MiddlewareProtocol<State, Action> {
  /// A type that holds the current state of the reducer.
  associatedtype State

  /// A type that holds all possible actions that cause the ``State`` of the reducer to change
  /// and/or kick off a side ``EffectTask`` that can communicate with the outside world.
  associatedtype Action

  // NB: For Xcode to favor autocompleting `var body: Body` over `var body: Never` we must use a
  //     type alias.
  associatedtype _Body

  /// A type representing the body of this reducer.
  ///
  /// When you create a custom reducer by implementing the ``body-swift.property-7foai``, Swift
  /// infers this type from the value returned.
  ///
  /// If you create a custom reducer by implementing the ``reduce(into:action:)-8yinq``, Swift
  /// infers this type to be `Never`.
  typealias Body = _Body
  /// Evolves the current state of the reducer to the next state.
  ///
  /// Implement this requirement for "primitive" reducers, or reducers that work on leaf node
  /// features. To define a reducer by combining the logic of other reducers together, implement
  /// the ``body-swift.property-97ymy`` requirement instead.
  ///
  /// - Parameters:
  ///   - state: The current state of the reducer.
  ///   - action: An action that can cause the state of the reducer to change, and/or kick off a
  ///     side effect that can communicate with the outside world.
  /// - Returns: An effect that can communicate with the outside world and feed actions back into
  ///   the system.

  func handle(action: Action, from dispatcher: ActionSource, state: @escaping GetState<State>) -> IO<Action>

  /// The content and behavior of a reducer that is composed from other reducers.
  ///
  /// Implement this requirement when you want to incorporate the behavior of other reducers
  /// together.
  ///
  /// Do not invoke this property directly.
  ///
  /// > Important: if your reducer implements the ``reduce(into:action:)-8yinq`` method, it will
  /// > take precedence over this property, and only ``reduce(into:action:)-8yinq`` will be called
  /// > by the ``Store``. If your reducer assembles a body from other reducers and has additional
  /// > business logic it needs to layer into the system, introduce this logic into the body
  /// > instead, either with ``Reduce``, or with a separate, dedicated conformance.
  @MiddlewareBuilder<State, Action>
  var body: Body { get }
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

extension MiddlewareProtocol where Body == Never {

  @_transparent
  public var body: Body {
    fatalError(
      """
      '\(Self.self)' has no body.
      """
    )
  }
}

extension MiddlewareProtocol where Body: MiddlewareProtocol, Body.State == State, Body.Action == Action {

}

// NB: This is available only in Swift 5.7.1 due to the following bug:
//     https://github.com/apple/swift/issues/60550
#if swift(>=5.7.1)
/// A convenience for constraining a ``MiddlewareProtocol`` conformance. Available only in Swift
/// 5.7.1.
///
/// This allows you to specify the `body` of a ``MiddlewareProtocol`` conformance like so:
///
/// ```swift
/// var body: some MiddlewareProtocolOf<Self> {
///   // ...
/// }
/// ```
///
/// …instead of the more verbose:
///
/// ```swift
/// var body: some MiddlewareProtocol<State, Action> {
///   // ...
/// }
/// ```

public typealias MiddlewareProtocolOf<M: MiddlewareProtocol> = MiddlewareProtocol<M.State, M.Action>
#endif
