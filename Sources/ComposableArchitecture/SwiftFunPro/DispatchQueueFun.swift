import Foundation
/// Description
/// - Parameter work: work description
public func withMainAsync(execute work: @escaping @convention(block) () -> Void) {
  DispatchQueue.main.async(execute: work)
}

/// Description
/// - Parameters:
///   - delay: delay description
///   - work: work description
public func withMainAsync(delay: TimeInterval, execute work: @escaping @convention(block) () -> Void) {
  DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
}
