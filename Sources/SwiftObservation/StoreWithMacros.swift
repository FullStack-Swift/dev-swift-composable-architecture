import Observation
import Combine
import Foundation

@available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
@Observable
public final class Store<State, Action> {
  
  public typealias Reducer = (inout State, Action) -> ()
  
  public typealias Middleware = (State, Action) -> AnyPublisher<Action, Never>?
  
  public private(set) var state: State
  
  private var cancellables: Set<AnyCancellable> = []
  
  let middlewares: [Middleware]
  
  private let reducer: Reducer
  
  public init(
    initialState state: State,
    middlewares: [Middleware] = [],
    reducer: @escaping Reducer
  ) {
    self.state = state
    self.middlewares = middlewares
    self.reducer = reducer
  }
  
  public func send(_ action: Action) {
    dispatch(action)
  }
  
  func dispatch(_ action: Action) {
    reducer(&state, action)
    for mw in middlewares {
      guard let middleware = mw(state, action) else {
        break
      }
      middleware
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: dispatch)
        .store(in: &cancellables)
    }
  }
}
