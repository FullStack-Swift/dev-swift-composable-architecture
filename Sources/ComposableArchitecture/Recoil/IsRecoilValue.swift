import Foundation

/// A func is Check an Object is a Atom
public func isRecoilValue<V>(type: V) -> Bool {
  if type is (any Atom) {
    return true
  }
  return false
}
