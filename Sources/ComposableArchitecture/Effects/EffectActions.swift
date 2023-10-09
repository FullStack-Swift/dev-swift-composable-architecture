extension Effect {
  @_spi(Internals)
  public var actions: AsyncStream<Action> {
    switch self.operation {
      case .none:
        return .finished
      case let .publisher(publisher):
        return AsyncStream { continuation in
          let cancellable = publisher.sink(
            receiveCompletion: { _ in continuation.finish() },
            receiveValue: { continuation.yield($0) }
          )
          continuation.onTermination = { _ in
            cancellable.cancel()
          }
        }
      case let .run(priority, operation):
        return AsyncStream { continuation in
          let task = Task(priority: priority) {
            await operation(Send { action in continuation.yield(action) })
            continuation.finish()
          }
          continuation.onTermination = { _ in task.cancel() }
        }
    }
  }
  
  @_spi(Internals)
  public var _actions: AsyncThrowingStream<Action, Error> {
    switch self.operation {
      case .none:
        return .finished(throwing: nil)
      case let .publisher(publisher):
        return AsyncThrowingStream { continuation in
          let cancellable = publisher.sink(
            receiveCompletion: { _ in continuation.finish() },
            receiveValue: { continuation.yield($0) }
          )
          continuation.onTermination = { _ in
            cancellable.cancel()
          }
        }
      case let .run(priority, operation):
        return AsyncThrowingStream { continuation in
          let task = Task(priority: priority) {
            await operation(Send { action in continuation.yield(action) })
            continuation.finish()
          }
          continuation.onTermination = { _ in task.cancel() }
        }
    }
  }
}
