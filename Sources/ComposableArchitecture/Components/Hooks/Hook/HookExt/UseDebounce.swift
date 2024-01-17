import Foundation
import Combine

/// Delay the execution of function or state update with useDebounce.

/// The useDebounce hook is useful for delaying the execution of functions or state updates until a specified time period has passed without any further changes to the input value. This is especially useful in scenarios such as handling user input or triggering network requests, where it effectively reduces unnecessary computations and ensures that resource-intensive operations are only performed after a pause in the input activity.
///
/// - Parameters:
///   - value: The value that you want to debounce. This can be of any type.
///   - delay: The delay time in milliseconds. After this amount of time, the latest value is used.
/// - Returns: The debounced value. After the delay time has passed without the value changing, this will be updated to the latest value.
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public func useDebounce<Output>(
  updateStrategy: HookUpdateStrategy? = .once,
  _ operation: AsyncThrowingStream<Output, any Error>,
  seconds timeInterval: TimeInterval = 2
) -> AsyncPhase<Output, any Error> {
  let stream = operation.debounce(for: .seconds(timeInterval))
    .eraseToThrowingStream()
  return useAsyncThrowingSequence(.once, stream)
}

/// Delay the execution of function or state update with useDebounce.

/// The useDebounce hook is useful for delaying the execution of functions or state updates until a specified time period has passed without any further changes to the input value. This is especially useful in scenarios such as handling user input or triggering network requests, where it effectively reduces unnecessary computations and ensures that resource-intensive operations are only performed after a pause in the input activity.
///
/// - Parameters:
///   - value: The value that you want to debounce. This can be of any type.
///   - delay: The delay time in milliseconds. After this amount of time, the latest value is used.
/// - Returns: The debounced value. After the delay time has passed without the value changing, this will be updated to the latest value.
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public func useDebounce<Output>(
  updateStrategy: HookUpdateStrategy? = .once,
  _ operation: some Publisher<Output, any Error>,
  seconds timeInterval: TimeInterval = 2
) -> AsyncPhase<Output, any Error> {
  let stream = operation
    .backport.values
    .debounce(for: .seconds(timeInterval))
    .eraseToThrowingStream()
  return useAsyncThrowingSequence(.once, stream)
}

/// A hook to use memoized value preserved until it is updated at the timing determined with given `updateStrategy`.
///
/// Publishes elements only after a specified time interval elapses between events.
///
/// Use the ``Publisher/debounce(for:scheduler:options:)`` operator to control the number of values and time between delivery of values from the upstream publisher. This operator is useful to process bursty or high-volume event streams where you need to reduce the number of values delivered to the downstream to a rate you specify.
///
/// In this example, a ``PassthroughSubject`` publishes elements on a schedule defined by the `bounces` array. The array is composed of tuples representing a value sent by the ``PassthroughSubject``, and a <doc://com.apple.documentation/documentation/Foundation/TimeInterval> ranging from one-quarter second up to 2 seconds that drives a delivery timer. As the queue builds, elements arriving faster than one-half second `debounceInterval` are discarded, while elements arriving at a rate slower than `debounceInterval` are passed through to the ``Publisher/sink(receiveValue:)`` operator.
///
///     let bounces:[(Int,TimeInterval)] = [
///         (0, 0),
///         (1, 0.25),  // 0.25s interval since last index
///         (2, 1),     // 0.75s interval since last index
///         (3, 1.25),  // 0.25s interval since last index
///         (4, 1.5),   // 0.25s interval since last index
///         (5, 2)      // 0.5s interval since last index
///     ]
///
///     let subject = PassthroughSubject<Int, Never>()
///     cancellable = subject
///         .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
///         .sink { index in
///             print ("Received index \(index)")
///         }
///
///     for bounce in bounces {
///         DispatchQueue.main.asyncAfter(deadline: .now() + bounce.1) {
///             subject.send(bounce.0)
///         }
///     }
///
///     // Prints:
///     //  Received index 1
///     //  Received index 4
///     //  Received index 5
///
///     //  Here is the event flow shown from the perspective of time, showing value delivery through the `debounce()` operator:
///
///     //  Time 0: Send index 0.
///     //  Time 0.25: Send index 1. Index 0 was waiting and is discarded.
///     //  Time 0.75: Debounce period ends, publish index 1.
///     //  Time 1: Send index 2.
///     //  Time 1.25: Send index 3. Index 2 was waiting and is discarded.
///     //  Time 1.5: Send index 4. Index 3 was waiting and is discarded.
///     //  Time 2: Debounce period ends, publish index 4. Also, send index 5.
///     //  Time 2.5: Debounce period ends, publish index 5.
///
/// - Parameters:
///   - dueTime: The time the publisher should wait before publishing an element.
///   - scheduler: The scheduler on which this publisher delivers elements
///   - options: Scheduler options that customize this publisher’s delivery of elements.
/// - Returns: A publisher that publishes events only after a specified time elapses.

@discardableResult
public func useOnChangedDebounce<Node: Equatable>(
  _ value: Node,
  second: Double = 0.5,
  effect: (() -> Void)? = nil
) -> Node {
  @HRef
  var cache: Node? = nil
  
  let ps = useMemo(.once) {
    PassthroughSubject<Node, Never>()
  }
  
  let asyncPhase = usePublisher(.once) {
    return ps
      .debounce(for: .seconds(second), scheduler: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
  
  useLayoutEffect(.preserved(by: value)) {
    ps.send(value)
    return nil
  }
  
  useLayoutEffect(
    .preserved(by: asyncPhase.value),
    where: asyncPhase.status == .success
  ) {
    if cache != value {
      if cache != nil {
        effect?()
      }
      cache = value
    }
  }
  return cache ?? value
}
