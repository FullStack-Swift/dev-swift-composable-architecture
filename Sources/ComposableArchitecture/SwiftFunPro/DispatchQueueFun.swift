import Foundation
/// Description
/// - Parameter work: work description
public func withMainAsync(
  execute work: @escaping @convention(block) () -> Void
) {
  DispatchQueue.main.async(execute: work)
}

/// Description
/// - Parameters:
///   - delay: delay description
///   - work: work description
public func withMainAsync(
  delay: TimeInterval,
  execute work: @escaping @convention(block) () -> Void
) {
  DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
}

public let mainQueue = DispatchQueue.main

public let serialQueue = DispatchQueue(
  label: "dq.serial.queue"
)

public let concurrentQueue = DispatchQueue(
  label: "dq.concurrent.queue",
  attributes: .concurrent
)
