
public struct IgnoreStateReducer<State, Action>: ReducerProtocol {
  @usableFromInline
  let ignoreStateReducer: (Action) -> Void

  @usableFromInline
  init(
    internal ignoreStateReducer: @escaping (Action) -> Void
  ) {
    self.ignoreStateReducer = ignoreStateReducer
  }

  /// Initializes a reducer with a `reduce` function.
  ///
  /// - Parameter reduce: A function that is called when ``reduce(into:action:)`` is invoked.
  @inlinable
  public init(_ ignoreStateReducer: @escaping (Action) -> Void) {
    self.init(internal: ignoreStateReducer)
  }

  @inlinable
  public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    self.ignoreStateReducer(action)
    return .none
  }
}
