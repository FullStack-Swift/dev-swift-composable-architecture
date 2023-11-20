import Foundation
/// Description:A hook will reset in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - initialNode: the any Atom value.
/// - Returns: Void
@MainActor
public func useRecoilReset<Node: Atom>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ initialNode: Node
) {
  let ref = RecoilHookRef(location: SourceLocation(fileID: fileID, line: line), initialNode: initialNode)
  ref.context.reset(ref.node)
}
