import Foundation

public func isRecoilValue<V>(type: V) -> Bool {
  if type is (any Atom) {
    return true
  }
  return false
}
