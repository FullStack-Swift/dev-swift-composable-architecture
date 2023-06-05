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

extension CurrentValueSubject {
  public func commit(_ block: (inout Output) -> Void) {
    var clone = self.value
    block(&clone)
    self.value = clone
  }
}
