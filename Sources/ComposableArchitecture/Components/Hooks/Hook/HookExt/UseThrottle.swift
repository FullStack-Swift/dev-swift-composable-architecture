import Foundation
import Combine

/// Throttle computationally expensive operations with useThrottle.
///
/// DESCRIPTION:
/// The useThrottle hook offers a controlled way to manage execution frequency in a React application. By accepting a value and an optional interval, it ensures that the value is updated at most every interval milliseconds. This is particularly helpful for limiting API calls, reducing UI updates, or mitigating performance issues by throttling computationally expensive operations.
/// - Parameters:
///   - value: The value to throttle.
///   - delay: (Optional) The interval in milliseconds. Default: 500ms.
/// - Returns: The throttled value that is updated at most once per interval.
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public func useThrottle<Output>(
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ operation: AsyncThrowingStream<Output, any Error>,
  seconds timeInterval: TimeInterval = 2
) -> AsyncPhase<Output, any Error> {
  let stream = operation.throttle(for: .seconds(timeInterval))
    .eraseToThrowingStream()
  return useAsyncThrowingSequence(.once, stream)
}


@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public func useThrottle<Output>(
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ operation: some Publisher<Output, any Error>,
  seconds timeInterval: TimeInterval = 2
) -> AsyncPhase<Output, any Error> {
  let stream = operation
    .backport.values
    .throttle(for: .seconds(timeInterval))
    .eraseToThrowingStream()
  return useAsyncThrowingSequence(.once, stream)
}


