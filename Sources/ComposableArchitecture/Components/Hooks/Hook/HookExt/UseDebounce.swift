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
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ operation: AsyncThrowingStream<Output, any Error>,
  seconds timeInterval: TimeInterval = 2
) -> AsyncPhase<Output, any Error> {
  let stream = operation.debounce(for: .seconds(timeInterval))
    .eraseToThrowingStream()
  return useAsyncThrowingSequence(.once, stream)
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public func useDebounce<Output>(
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ operation: some Publisher<Output, any Error>,
  seconds timeInterval: TimeInterval = 2
) -> AsyncPhase<Output, any Error> {
  let stream = operation
    .backport.values
    .debounce(for: .seconds(timeInterval))
    .eraseToThrowingStream()
  return useAsyncThrowingSequence(.once, stream)
}
