#if canImport(ComposableArchitecture)
import ComposableArchitecture

public struct LazyReducer<Wrapped: Reducer>: Reducer {
  public typealias State = Wrapped.State
  public typealias Action = Wrapped.Action
  
  @usableFromInline
  let makeReducer: () -> Wrapped
  
  @usableFromInline
  var reducer: Indirect<Wrapped?> = .init(nil)
  
  @inlinable
  public init(
    @ReducerBuilder<State, Action> _ build: @escaping () -> Wrapped
  ) {
    self.makeReducer = build
  }
  
  @inlinable
  public init(
    _ reducer: @escaping @autoclosure () -> Wrapped
  ) {
    self.makeReducer = reducer
  }
  
  @inlinable
  public func reduce(
    into state: inout Wrapped.State, action: Wrapped.Action
  ) -> Effect<Wrapped.Action> {
    switch reducer.wrappedValue {
      case let .some(wrapped):
        return wrapped.reduce(into: &state, action: action)
      case .none:
        reducer._setValue(makeReducer())
        return reduce(into: &state, action: action)
    }
  }
}

#endif
