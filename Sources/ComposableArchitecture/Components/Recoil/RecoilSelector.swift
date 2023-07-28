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
public func selectorValue<State>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  _ initialState: @escaping (AtomTransactionContext<Void>) -> State
) -> MValueAtom<State> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  return MValueAtom<State>(id: id) { context in
    initialState(context)
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
public func selectorValue<State>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  _ initialState: State
) -> MValueAtom<State> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  return MValueAtom(id: id) { _ in
    initialState
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
public func selectorState<State>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  _ initialState: @escaping (AtomTransactionContext<Void>) -> State
) -> MStateAtom<State> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  return MStateAtom<State>(id: id) { context in
    return initialState(context)
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
public func selectorState<State>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  _ initialState: State
) -> MStateAtom<State> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  return MStateAtom<State>(id: id) { _ in
    initialState
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
public func selectorTask<State>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  _ initialState: @escaping (AtomTransactionContext<Void>) async -> State
) -> MTaskAtom<State> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  return MTaskAtom(id: id, initialState)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func selectorTask<State>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  _ initialState: @escaping () async -> State
) -> MTaskAtom<State> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  return MTaskAtom(id: id, initialState)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func selectorThrowingTask<State>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  _ initialState: @escaping (AtomTransactionContext<Void>) async throws -> State
) -> MThrowingTaskAtom<State> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  return MThrowingTaskAtom(id: id, initialState)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func selectorThrowingTask<State>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  _ initialState: @escaping () async throws -> State
) -> MThrowingTaskAtom<State> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  return MThrowingTaskAtom(id: id, initialState)
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
  _ initialState: @escaping (AtomTransactionContext<Void>) -> Publisher
) -> MPublisherAtom<Publisher> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  return MPublisherAtom(id: id, initialState)
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
  _ initialState: Publisher
) -> MPublisherAtom<Publisher> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  return MPublisherAtom(id: id, initialState)
}
