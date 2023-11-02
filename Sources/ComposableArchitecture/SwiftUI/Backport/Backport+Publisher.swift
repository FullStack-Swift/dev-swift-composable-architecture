import Combine

public extension Publisher {
  var backport: Backport<Self> { Backport(self) }
}

public extension Backport where Base: Publisher {
  /// Convert this publisher into an `AsyncThrowingStream` that
  /// can be iterated over asynchronously using `for try await`.
  /// The stream will yield each output value produced by the
  /// publisher and will finish once the publisher completes.
  var values: AsyncThrowingStream<Base.Output, Error> {
    AsyncThrowingStream { continuation in
      var cancellable: AnyCancellable?
      let onTermination = { cancellable?.cancel() }
      
      continuation.onTermination = { @Sendable _ in
        onTermination()
      }
      
      cancellable = base.eraseToAnyPublisher()
        .sink(
          receiveCompletion: { completion in
            switch completion {
              case .finished:
                continuation.finish()
              case .failure(let error):
                continuation.finish(throwing: error)
            }
          }, receiveValue: { value in
            continuation.yield(value)
          }
        )
    }
  }
}

public extension Publisher where Failure == Never {
  /// Convert this publisher into an `AsyncStream` that can
  /// be iterated over asynchronously using `for await`. The
  /// stream will yield each output value produced by the
  /// publisher and will finish once the publisher completes.
  var values: AsyncStream<Output> {
    AsyncStream { continuation in
      var cancellable: AnyCancellable?
      let onTermination = { cancellable?.cancel() }
      
      continuation.onTermination = { @Sendable _ in
        onTermination()
      }
      
      cancellable = sink(
        receiveCompletion: { _ in
          continuation.finish()
        }, receiveValue: { value in
          continuation.yield(value)
        }
      )
    }
  }
}

