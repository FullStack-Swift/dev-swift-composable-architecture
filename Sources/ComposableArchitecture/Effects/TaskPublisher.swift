import Combine

/// Async Task to Publisher
public func withPublisher<Output>(_ work: @escaping () async -> Output) -> TaskPublisher<Output> {
  TaskPublisher(work: work)
}

public struct TaskPublisher<Output>: Publisher {
  public typealias Failure = Never

  let work: () async -> Output

  init(work: @escaping () async -> Output) {
    self.work = work
  }

  public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
    let subscription = TaskSubscription(work: work, subscriber: subscriber)
    subscriber.receive(subscription: subscription)
    subscription.start()
  }

  final class TaskSubscription<Downstream: Subscriber>: Combine.Subscription where Downstream.Input == Output, Downstream.Failure == Never {
    private var handle: Task<Output, Never>?
    private let work: () async -> Output
    private let subscriber: Downstream

    init(work: @escaping () async -> Output, subscriber: Downstream) {
      self.work = work
      self.subscriber = subscriber
    }

    func start() {
      self.handle = Task.init { [subscriber, work] in
        let result = await work()
        _ = subscriber.receive(result)
        subscriber.receive(completion: .finished)
        return result
      }
    }

    func request(_ demand: Subscribers.Demand) {}

    func cancel() {
      handle?.cancel()
    }
  }
}

/// Async Task to Publisher
public func withThrowingPublisher<Output>(_ work: @escaping () async throws -> Output) -> TaskThrowsPublisher<Output> {
  TaskThrowsPublisher(work: work)
}

public struct TaskThrowsPublisher<Output>: Publisher {

  public typealias Failure = any Error

  let work: () async throws -> Output

  init(work: @escaping () async throws -> Output) {
    self.work = work
  }

  public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
    let subscription = TaskSubscription(work: work, subscriber: subscriber)
    subscriber.receive(subscription: subscription)
    subscription.start()
  }

  final class TaskSubscription<Downstream: Subscriber>: Combine.Subscription where Downstream.Input == Output, Downstream.Failure == Failure {
    private var handle: Task<Output, Failure>?
    private let work: () async throws -> Output
    private let subscriber: Downstream

    init(work: @escaping () async throws -> Output, subscriber: Downstream) {
      self.work = work
      self.subscriber = subscriber
    }

    func start() {
      self.handle = Task.init { [subscriber, work] in
        do {
          let result = try await work()
          _ = subscriber.receive(result)
          subscriber.receive(completion: .finished)
          return result
        } catch {
          subscriber.receive(completion: .failure(error))
          throw error
        }

      }
    }

    func request(_ demand: Subscribers.Demand) {}

    func cancel() {
      handle?.cancel()
    }
  }
}

public func withTaskResultPublisher<Success: Sendable>(_ work: @escaping () async -> TaskResult<Success>) -> TaskResultPublisher<Success> {
  TaskResultPublisher(work: work)
}

public struct TaskResultPublisher<Success: Sendable>: Publisher {
  public typealias Failure = Never
  public typealias Output = TaskResult<Success>

  let work: () async -> Output

  init(work: @escaping () async -> Output) {
    self.work = work
  }

  public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
    let subscription = TaskSubscription(work: work, subscriber: subscriber)
    subscriber.receive(subscription: subscription)
    subscription.start()
  }

  final class TaskSubscription<Output, Downstream: Subscriber>: Combine.Subscription where Downstream.Input == Output, Downstream.Failure == Never {
    private var handle: Task<Output, Never>?
    private let work: () async -> Output
    private let subscriber: Downstream

    init(work: @escaping () async -> Output, subscriber: Downstream) {
      self.work = work
      self.subscriber = subscriber
    }

    func start() {
      self.handle = Task.init { [subscriber, work] in
        let result = await work()
        _ = subscriber.receive(result)
        subscriber.receive(completion: .finished)
        return result
      }
    }

    func request(_ demand: Subscribers.Demand) {}

    func cancel() {
      handle?.cancel()
    }
  }
}
