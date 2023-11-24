/// A protocol that describes how to create effect of an application to render state,
/// given an action and describes new ``action``s should be excuted later by the store
///
///Confirm types to this protocol to respresent the domain, logic
///
public protocol Middleware<State, Action> {
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
  /// When you create a custom reducer by implementing the ``body-92nwi``, Swift
  /// infers this type from the value returned.
  ///
  /// If you create a custom reducer by implementing the ``handle(state:action:from:)-5eb4i``, Swift
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
  func handle(state: State, action: Action, from dispatcher: ActionSource) -> IO<Action>

  /// The content and behavior of a handle that is composed from other handles.
  ///
  /// Implement this requirement when you want to incorporate the behavior of other handles
  /// together.
  ///
  /// Do not invoke this property directly.
  ///
  /// > Important: if your reducer implements the ``handle(state:action:from:)-8yinq`` method, it will
  /// > take precedence over this property, and only ``handle(state:action:from:)-8yinq`` will be called
  /// > by the ``Store``. If your handle assembles a body from other reducers and has additional
  /// > business logic it needs to layer into the system, introduce this logic into the body
  /// > instead, either with ``IOMiddleware``, or with a separate, dedicated conformance.
  @MiddlewareBuilder<State, Action>
  var body: Body { get }
}

extension Middleware where Body == Never {

  @_transparent
  public var body: Body {
    fatalError(
      """
      '\(Self.self)' has no body.
      """
    )
  }
}

extension Middleware where Body: Middleware, Body.State == State, Body.Action == Action {

  public func handle(state: State, action: Action, from dispatcher: ActionSource) -> IO<Action> {
    self.body.handle(state: state, action: action, from: dispatcher)
  }

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

public typealias MiddlewareOf<M: Middleware> = Middleware<M.State, M.Action>
#endif
