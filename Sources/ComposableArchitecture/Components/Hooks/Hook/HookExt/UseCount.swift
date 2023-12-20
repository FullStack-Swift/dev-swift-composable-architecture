import Foundation

public func useCount(
  _ updateStrategy: HookUpdateStrategy = .once
) -> Int {
  @HRef var count = 0
  useMemo(updateStrategy) {
    count += 1
  }
  return count
}
