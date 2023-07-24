import Foundation

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func atomFamily<Value>(
  fileID: String = #fileID,
  line: UInt = #line,
  key: String,
  _ initialState: @escaping (MStateAtom<Value>.Context) -> Value
) -> MStateAtom<Value> {
  let sourceLocation = SourceLocation(fileID: fileID, line: line)
  print(sourceLocation)
  return MStateAtom(id: key, initialState)
}

public class RecoilFamily<T> {
  
}
