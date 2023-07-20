import Foundation

@MainActor
public func atomFamily<Value>(
  key: String,
  _ initialState: @escaping (MStateAtom<Value>.Context) -> Value,
  fileID: String = #fileID,
  line: UInt = #line
) -> MStateAtom<Value> {
  let sourceLocation = SourceLocation(fileID: fileID, line: line)
  print(sourceLocation)
  return MStateAtom(id: key, initialState)
}

public class RecoilFamily<T> {
  
}
