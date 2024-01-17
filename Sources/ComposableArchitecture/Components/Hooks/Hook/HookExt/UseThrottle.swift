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
  updateStrategy: HookUpdateStrategy? = .once,
  _ operation: AnyAsyncSequence<Output>,
  seconds timeInterval: Double = 0.5
) -> AsyncPhase<Output, any Error> {
  let stream = operation
    ._throttle(for: .seconds(timeInterval))
    .eraseToThrowingStream()
  return useAsyncThrowingSequence(updateStrategy, stream)
}


@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public func useThrottle<Output>(
  updateStrategy: HookUpdateStrategy? = .once,
  _ operation: some Publisher<Output, any Error>,
  seconds timeInterval: TimeInterval = 0.5
) -> AsyncPhase<Output, any Error> {
  let stream = operation
    .backport.values
    ._throttle(for: .seconds(timeInterval))
    .eraseToThrowingStream()
  return useAsyncThrowingSequence(updateStrategy, stream)
}

/// A hook to use memoized value preserved until it is updated at the timing determined with given `updateStrategy`.
@discardableResult
public func useOnChangedThrottle<Node: Equatable>(
  _ value: Node,
  second: Double = 0.5,
  effect: (() -> Void)? = nil
) -> Node {
  @HRef
  var cache: Node? = nil
  
  let ps = useMemo(.once) {
    PassthroughSubject<Node, Never>()
  }
  
  useLayoutEffect(.preserved(by: value)) {
    ps.send(value)
    return nil
  }
  
  let asyncPhase = usePublisher(.once) {
    return ps
      .throttle(for: .seconds(second), scheduler: DispatchQueue.main, latest: true)
      .eraseToAnyPublisher()
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


