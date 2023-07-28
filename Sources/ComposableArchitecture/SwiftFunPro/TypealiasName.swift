import Foundation
import Combine

// MARK: Combine
public typealias SetCancellables = Set<AnyCancellable>

public typealias ActionSubject<Action> = PassthroughSubject<Action, Never>

public typealias StateSubject<State> = CurrentValueSubject<State, Never>

public typealias ObservableEvent = PassthroughSubject<(), Never>

// MARK: Function
public typealias CompletionFunction<C> = (C) -> ()

public typealias CallBackFunction = () -> ()

struct UniqueKey: Hashable {}

struct Pair<T: Equatable>: Equatable {
  let first: T
  let second: T
}

final public class AsyncThrowingStreamPipe<Element> {
  private(set) var stream: AsyncThrowingStream<Element, Error>
  private(set) var continuation: AsyncThrowingStream<Element, Error>.Continuation!
  
  public init() {
    (stream, continuation) = Self.pipe()
  }
  
  public func reset() {
    (stream, continuation) = Self.pipe()
  }
  
  public static func pipe() -> (
    AsyncThrowingStream<Element, Error>,
    AsyncThrowingStream<Element, Error>.Continuation
  ) {
    var continuation: AsyncThrowingStream<Element, Error>.Continuation!
    let stream = AsyncThrowingStream { continuation = $0 }
    return (stream, continuation)
  }
}
