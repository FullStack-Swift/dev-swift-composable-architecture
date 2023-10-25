import Foundation

/// Utilty for applying a transform to a value.
/// - Parameters:
///   - transform: The transform to apply.
///   - input: The value to be transformed.
/// - Returns: The transformed value.
public func apply<T>(_ transform: (inout T) -> Void, to input: T) -> T {
  var transformed = input
  transform(&transformed)
  return transformed
}

/// return description sourceId
/// - Parameters:
///   - id: id description
///   - fileID: fileID description
///   - line: line description
/// - Returns: description
public func sourceId(
  id: String = "",
  fileID: String = #fileID,
  line: UInt = #line
) -> String {
  if id.isEmpty {
    return "fileID: \(fileID) line: \(line)"
  } else {
    return "fileID: \(fileID) line: \(line) id: \(id)"
  }
}

///
/// Submits a work item to a dispatch queue and optionally associates it with a
/// dispatch group. The dispatch group may be used to wait for the completion
/// of the work items it references.
///
/// This method enforces the work item to be sendable.

public func mainAsync(
  execute work: @escaping @convention(block) () -> Void
) {
  DispatchQueue.main.async(execute: work)
}

///
/// Submits a work item to a dispatch queue for asynchronous execution after
/// a specified time.
///
/// This method enforces the work item to be sendable.
///
/// - parameter: deadline the time after which the work item should be executed,
/// given as a `DispatchTime`.
public func mainAsyncAfter(
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
