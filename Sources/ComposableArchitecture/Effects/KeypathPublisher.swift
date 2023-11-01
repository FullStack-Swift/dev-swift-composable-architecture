import Combine

@dynamicMemberLookup
public struct KeyPathPublisher<Output, Failure: Error>: Publisher {

  public let upstream: AnyPublisher<Output, Failure>

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
    dynamicMember keyPath: KeyPath<Output, Value>
  ) -> KeyPathPublisher<Value, Failure> {
    .init(upstream: self.upstream.map(keyPath).removeDuplicates())
  }
}

extension Publisher {
  /// Returns the resulting publisher of a given key path.
  public func toKeyPathPublisher() -> KeyPathPublisher<Output, Failure> {
    KeyPathPublisher(upstream: self)
  }
}
