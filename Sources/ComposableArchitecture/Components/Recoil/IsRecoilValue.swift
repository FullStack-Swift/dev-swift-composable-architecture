import Foundation

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func isRecoilValue<V>(type: V) -> Bool {
  if type is (any Atom) {
    return true
  }
  return false
}
