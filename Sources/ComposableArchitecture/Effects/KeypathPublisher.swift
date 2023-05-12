import Combine

/// A publisher of store state.
@dynamicMemberLookup
public struct KeyPathPublisher<State>: Publisher {
  public typealias Output = State
  public typealias Failure = Never

  public let upstream: AnyPublisher<State, Never>

  public func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
    self.upstream.subscribe(
      AnySubscriber(
        receiveSubscription: subscriber.receive(subscription:),
        receiveValue: subscriber.receive(_:),
        receiveCompletion: {
          subscriber.receive(completion: $0)
        }
      )
    )
  }

  public init<P: Publisher>(
    upstream: P
  ) where P.Output == Output, P.Failure == Failure {
    self.upstream = upstream.eraseToAnyPublisher()
  }

  /// Returns the resulting publisher of a given key path.
  public subscript<Value: Equatable>(
    dynamicMember keyPath: KeyPath<State, Value>
  ) -> KeyPathPublisher<Value> {
    .init(upstream: self.upstream.map(keyPath).removeDuplicates())
  }
}
