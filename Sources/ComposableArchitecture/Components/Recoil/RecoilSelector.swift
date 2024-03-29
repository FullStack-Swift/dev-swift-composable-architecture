import Foundation
import Combine
import SwiftUI

/// Primitive and flexible state management

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func selectorValue<Node>(
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
public func selectorValue<Node>(
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
public func selectorState<Node>(
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
public func selectorState<Node>(
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
public func selectorTask<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
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
/// - Returns: Hook Value.
@MainActor
public func selectorTask<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
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
public func selectorThrowingTask<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
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
public func selectorThrowingTask<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
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
public func selectorPublisher<Publisher: Combine.Publisher>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  _ initialNode: @escaping (AtomTransactionContext<Void>) -> Publisher
) -> MPublisherAtom<Publisher> {
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
public func selectorPublisher<Publisher: Combine.Publisher>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  _ initialNode: Publisher
) -> MPublisherAtom<Publisher> {
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
public func selectorAsyncSequence<Node: AsyncSequence>(
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
public func selectorAsyncSequence<Node: AsyncSequence>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  _ initialNode: Node
) -> MAsyncSequenceAtom<Node> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  return MAsyncSequenceAtom(id: id, initialNode)
}
