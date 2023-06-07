import Combine

public extension Publisher where Output == Never, Failure == Never {
  func start() -> Cancellable {
    return sink(receiveValue: { _ in })
  }
}

public extension Publisher where Self.Failure == Never {
  func assign<Root: AnyObject>(
    to keyPath: WritableKeyPath<Root, Self.Output>,
    weakly object: Root
  ) -> AnyCancellable {
    return self.sink { [weak object] output in
      object?[keyPath: keyPath] = output
    }
  }
}

public extension Publisher {
  func replaceError(
    replace: @escaping (Failure) -> Self.Output
  ) -> AnyPublisher<Self.Output, Never> {
    return `catch` { error in
      Result.Publisher(replace(error))
    }.eraseToAnyPublisher()
  }

  func ignoreError() -> AnyPublisher<Output, Never> {
    return `catch` { _ in
      Empty()
    }.eraseToAnyPublisher()
  }
}

extension AnyPublisher {
  func bindValue<S: Subject>(
    subject: S
  ) -> AnyCancellable where S.Output == Output?, S.Failure == Failure {
    sink { completion in
      /// don't send completion
      /// subject.send(completion: completion)
    } receiveValue: { ouput in
      subject.send(ouput)
    }
  }
}

public extension AnyPublisher where Failure == Never {
  func start() -> Cancellable {
    return sink(receiveValue: { _ in })
  }
}

public typealias ActionSubject<Action> = PassthroughSubject<Action, Never>

extension CurrentValueSubject {
  public func commit(_ block: (inout Output) -> Void) {
    var clone = self.value
    block(&clone)
    self.value = clone
  }
}

//extension Task {
//  /// A publisher for Task
//  final class Publisher<Output> {
//
//    private let handle: () async -> Output
//
//    init(handle: @escaping () async -> Output) {
//      self.handle = handle
//    }
//  }
//}
//
//extension Task.Publisher: Publisher {
//  typealias Output = Output
//
//  typealias Failure = Never
//
//  func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Output == S.Input {
//    let subscription = Task.Subscription(handle, downstream: subscriber)
//    subscriber.receive(subscription: subscription)
//  }
//
//
//}
//
//extension Task {
//  /// A Subscription for Task
//  final class Subscription {
//    typealias Output =  Task.Success
//    init<DownStream>(_ handle: @escaping () async -> Output, downstream: DownStream) where DownStream: Subscriber, Output == DownStream.Output, Failure == DownStream.Failure {
//
//    }
//
//  }
//}
//
//extension Task.Subscription: Subscription {
//  func request(_ demand: Subscribers.Demand) {
//    guard demand > 0 else {
//      return
//    }
//  }
//
//  func cancel() {
//
//  }
//}


extension Publisher where Failure == Never {
  /// Converts publisher to AsyncSequence
  var valuesAsync: any AsyncSequence {
    if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
      return values
    } else {
      return _AsyncPublisher(self)
    }
  }
}

/// AsyncSequence from a Publisher that never errors.
/// Combine.AsyncPublisher is used when available, otherwise AsyncStream is used.
struct _AsyncPublisher<P>: AsyncSequence where P: Publisher, P.Failure == Never {
  typealias Element = P.Output

  private let publisher: P
  init(_ publisher: P) {
    self.publisher = publisher
  }

  func makeAsyncIterator() -> Iterator {
    if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
      var iterator = Combine.AsyncPublisher(publisher).makeAsyncIterator()
      return Iterator { await iterator.next() }
    } else {
      var iterator = makeAsyncStream().makeAsyncIterator()
      return Iterator { await iterator.next() }
    }
  }

  struct Iterator: AsyncIteratorProtocol {
    let _next: () async -> P.Output?

    mutating func next() async -> P.Output? {
      await _next()
    }
  }

  private func makeAsyncStream() -> AsyncStream<Element> {
    AsyncStream(Element.self, bufferingPolicy: .bufferingOldest(1)) { continuation in
      publisher.receive(subscriber: Inner(continuation: continuation))
    }
  }
}

private extension _AsyncPublisher {
  final class Inner: Subscriber {
    typealias Continuation = AsyncStream<Input>.Continuation
    private var subscription: Subscription?
    private let continuation: Continuation

    init(continuation: Continuation) {
      self.continuation = continuation
      continuation.onTermination = cancel
    }

    func receive(subscription: Subscription) {
      self.subscription = subscription
      subscription.request(.max(1))
    }

    func receive(_ input: Element) -> Subscribers.Demand {
      continuation.yield(input)
      Task {  [subscription] in
        // Demand for next value is requested asynchronously allowing
        // synchronous publishers like Publishers.Sequence to yield and suspend.
        subscription?.request(.max(1))
      }
      return .none
    }

    func receive(completion: Subscribers.Completion<Never>) {
      subscription = nil
      continuation.finish()
    }

    @Sendable
    func cancel(_: Continuation.Termination) {
      subscription?.cancel()
      subscription = nil
    }
  }
}
