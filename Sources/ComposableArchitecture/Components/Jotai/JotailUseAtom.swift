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
public func useAtomValue<V>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String,
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialState: @escaping (AtomTransactionContext<Void>) -> V
) -> V {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atom: MValueAtom = atomValue(id: id, initialState)
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
public func useAtomValue<V>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String,
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialState: V
) -> V {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atom: MValueAtom = atomValue(id: id, initialState)
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
public func useAtomState<State>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String,
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialNode: @escaping (AtomTransactionContext<Void>) -> State
) -> Binding<State> {
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
public func useAtomState<State>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String,
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialState: State
) -> Binding<State> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atom: MStateAtom = atomState(id: id, initialState)
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
public func useAtomTask<V>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String,
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialState: @escaping () async -> V
) -> AsyncPhase<V, Never> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atom: MTaskAtom = atomTask(id: id, initialState)
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
public func useAtomTask<V>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String,
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialState: @escaping (AtomTransactionContext<Void>) async -> V
) -> AsyncPhase<V, Never> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atom: MTaskAtom = atomTask(id: id, initialState)
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
public func useAtomThrowingTask<V>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String,
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialState: @escaping () async throws -> V
) -> AsyncPhase<V, Error> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atom: MThrowingTaskAtom = atomThrowingTask(id: id, initialState)
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
public func useAtomThrowingTask<V>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String,
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialState: @escaping (AtomTransactionContext<Void>) async throws -> V
) -> AsyncPhase<V, Error> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atom: MThrowingTaskAtom = atomThrowingTask(id: id, initialState)
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
public func useAtomPublisher<Publisher: Combine.Publisher>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String,
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialState: Publisher
) -> AsyncPhase<Publisher.Output, Publisher.Failure> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atom: MPublisherAtom = atomPublisher(id: id, initialState)
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
public func useAtomPublisher<Publisher: Combine.Publisher>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String,
  updateStrategy: HookUpdateStrategy? = .once,
  _ initialState: @escaping (AtomTransactionContext<Void>) -> Publisher
) -> AsyncPhase<Publisher.Output, Publisher.Failure> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atom: MPublisherAtom = atomPublisher(id: id, initialState)
  return useRecoilPublisher(atom)
}
