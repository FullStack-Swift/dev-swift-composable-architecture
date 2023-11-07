import Foundation

/// We use `useFlagUpdated` to cache key update in` HookUpdateStrategy`. if condition == true, flag will toggle, and return new key to  HookUpdateStrategy.
/// It wil call once time when init, and then only condition == true, hook will updates state.
public func useFlagUpdated(_ condition: Bool? = false) -> Bool {
  @HState var flag = false
  if condition == true {
    flag.toggle()
  }
  return flag
}
