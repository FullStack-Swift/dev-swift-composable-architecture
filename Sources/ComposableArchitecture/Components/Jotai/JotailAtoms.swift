import Foundation
import Combine
import SwiftUI

// MARK: Create Atom

/// Primitive and flexible state management

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func atomValue<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  _ initialNode: @escaping (AtomTransactionContext<Void>) -> Node
) -> MValueAtom<Node> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  return MValueAtom(id: id) { context in
    initialNode(context)
  }
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func atomValue<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  _ initialNode: Node
) -> MValueAtom<Node> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  return MValueAtom(id: id) { _ in
    initialNode
  }
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func atomState<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  _ initialNode: @escaping (AtomTransactionContext<Void>) -> Node
) -> MStateAtom<Node> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  return MStateAtom(id: id) { context in
    return initialNode(context)
  }
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func atomState<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  _ initialNode: Node
) -> MStateAtom<Node> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  return MStateAtom(id: id) { _ in
    initialNode
  }
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func atomTask<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String,
  _ initialNode: @escaping (AtomTransactionContext<Void>) async -> Node
) -> MTaskAtom<Node> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  return MTaskAtom(id: id, initialNode)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.@MainActor
public func atomTask<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String,
  _ initialNode: @escaping () async -> Node
) -> MTaskAtom<Node> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  return MTaskAtom(id: id, initialNode)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func atomThrowingTask<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String,
  _ initialNode: @escaping (AtomTransactionContext<Void>) async throws -> Node
) -> MThrowingTaskAtom<Node> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  return MThrowingTaskAtom(id: id, initialNode)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func atomThrowingTask<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String,
  _ initialNode: @escaping () async throws -> Node
) -> MThrowingTaskAtom<Node> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  return MThrowingTaskAtom(id: id, initialNode)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func atomPublisher<Node: Combine.Publisher>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String,
  _ initialNode: @escaping (AtomTransactionContext<Void>) -> Node
) -> MPublisherAtom<Node> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  return MPublisherAtom(id: id, initialNode)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func atomPublisher<Node: Combine.Publisher>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String,
  _ initialNode: Node
) -> MPublisherAtom<Node> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  return MPublisherAtom(id: id, initialNode)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func atomAsyncSequence<Node: AsyncSequence>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  _ initialNode: @escaping (AtomTransactionContext<Void>) -> Node
) -> MAsyncSequenceAtom<Node> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  return MAsyncSequenceAtom(id: id, initialNode)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func atomAsyncSequence<Node: AsyncSequence>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  _ initialNode: Node
) -> MAsyncSequenceAtom<Node> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  return MAsyncSequenceAtom(id: id, initialNode)
}
