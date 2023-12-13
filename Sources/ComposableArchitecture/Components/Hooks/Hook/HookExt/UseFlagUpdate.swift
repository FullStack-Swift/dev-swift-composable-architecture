import Foundation

/// We use `useFlagUpdated` to cache key update in` HookUpdateStrategy`. if condition == true, flag will toggle, and return new key to  HookUpdateStrategy.
/// It wil call once time when init, and then if only condition == true, hook will updates state.
public func useFlagUpdated(_ condition: Bool? = false) -> Bool {
  @HState var flag = false
  if condition == true {
    flag.toggle()
  }
  return flag
}

/// We use `useFlagChanged` to cache key update in` HookUpdateStrategy`. if node != before node, flag will toggle, and return new key to  HookUpdateStrategy.
/// It wil call once time when init, and then if only node != before node, hook will updates state.
public func useFlagChanged<Node: Equatable>(_ node: Node) -> Bool {
  @HState var flag = false
  @HRef var ref = node
  if ref != node {
    ref = node
    flag.toggle()
  }
  return flag
}
