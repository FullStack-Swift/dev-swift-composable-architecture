import Combine
import SwiftUI

/// Primitve and flexible useAtom

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useAtomValue<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: @escaping (AtomTransactionContext<Void>) -> Node
) -> Node {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atom: MValueAtom = atomValue(id: id, initialNode)
  return useRecoilValue(atom)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useAtomValue<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: Node
) -> Node {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atom: MValueAtom = atomValue(id: id, initialNode)
  return useRecoilValue(atom)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useAtomState<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: @escaping (AtomTransactionContext<Void>) -> Node
) -> Binding<Node> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atom: MStateAtom = atomState(id: id, initialNode)
  return useRecoilState(updateStrategy: updateStrategy, atom)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useAtomState<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: Node
) -> Binding<Node> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atom: MStateAtom = atomState(id: id, initialNode)
  return useRecoilState(atom)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useAtomTask<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: @escaping () async -> Node
) -> AsyncPhase<Node, Never> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atom: MTaskAtom = atomTask(id: id, initialNode)
  return useRecoilTask(updateStrategy: .once, atom)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useAtomTask<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: @escaping (AtomTransactionContext<Void>) async -> Node
) -> AsyncPhase<Node, Never> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atom: MTaskAtom = atomTask(id: id, initialNode)
  return useRecoilTask(updateStrategy: .once, atom)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useAtomThrowingTask<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: @escaping () async throws -> Node
) -> AsyncPhase<Node, Error> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atom: MThrowingTaskAtom = atomThrowingTask(id: id, initialNode)
  return useRecoilThrowingTask(updateStrategy: .once, atom)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useAtomThrowingTask<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: @escaping (AtomTransactionContext<Void>) async throws -> Node
) -> AsyncPhase<Node, Error> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atom: MThrowingTaskAtom = atomThrowingTask(id: id, initialNode)
  return useRecoilThrowingTask(updateStrategy: .once, atom)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useAtomPublisher<Node: Combine.Publisher>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: Node
) -> AsyncPhase<Node.Output, Node.Failure> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atom: MPublisherAtom = atomPublisher(id: id, initialNode)
  return useRecoilPublisher(atom)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useAtomPublisher<Node: Combine.Publisher>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: @escaping (AtomTransactionContext<Void>) -> Node
) -> AsyncPhase<Node.Output, Node.Failure> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atom: MPublisherAtom = atomPublisher(id: id, initialNode)
  return useRecoilPublisher(atom)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useAtomRefresher<Node: Combine.Publisher>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: @escaping (AtomTransactionContext<Void>) -> Node
) -> (phase: AsyncPhase<MPublisherAtom<Node>.Publisher.Output, MPublisherAtom<Node>.Publisher.Failure>, refresher: () -> ()) {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atom: MPublisherAtom = atomPublisher(id: id, initialNode)
  return useRecoilRefresher(atom)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useAtomRefresher<Node: ThrowingTaskAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: @escaping (AtomTransactionContext<Void>) -> Node
) -> (phase: AsyncPhase<MThrowingTaskAtom<Node>.Loader.Success, MThrowingTaskAtom<Node>.Loader.Failure>, refresher: () -> ()) {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atom: MThrowingTaskAtom = atomThrowingTask(id: id, initialNode)
  return useRecoilRefresher(atom)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useAtomRefresher<Node: TaskAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: @escaping (AtomTransactionContext<Void>) -> Node
) -> (phase: AsyncPhase<MTaskAtom<Node>.Loader.Success, MTaskAtom<Node>.Loader.Failure>, refresher: () -> ()) {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atom: MTaskAtom = atomTask(id: id, initialNode)
  return useRecoilRefresher(atom)
}
