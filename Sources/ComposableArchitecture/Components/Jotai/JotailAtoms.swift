import Foundation
import Combine
import SwiftUI

/// Primitive and flexible state management

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func atomValue<State>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) -> State
) -> MValueAtom<State> {
  MValueAtom<State>(id: id) { context in
    initialState(context)
  }
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func atomValue<State>(
  id: String,
  _ initialState: State
) -> MValueAtom<State> {
  MValueAtom(id: id) { _ in
    initialState
  }
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func atomState<State>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) -> State
) -> MStateAtom<State> {
  MStateAtom<State>(id: id) { context in
    return initialState(context)
  }
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func atomState<State>(
  id: String,
  _ initialState: State
) -> MStateAtom<State> {
  MStateAtom<State>(id: id) { _ in
    initialState
  }
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func atomTask<State>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) async -> State
) -> MTaskAtom<State> {
  MTaskAtom(id: id, initialState)
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func atomTask<State>(
  id: String,
  _ initialState: @escaping () async -> State
) -> MTaskAtom<State> {
  MTaskAtom(id: id, initialState)
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func atomThrowingTask<State>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) async throws -> State
) -> MThrowingTaskAtom<State> {
  MThrowingTaskAtom(id: id, initialState)
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func atomThrowingTask<State>(
  id: String,
  _ initialState: @escaping () async throws -> State
) -> MThrowingTaskAtom<State> {
  MThrowingTaskAtom(id: id, initialState)
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func atomPublisher<Publisher: Combine.Publisher>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) -> Publisher
) -> MPublisherAtom<Publisher> {
  MPublisherAtom(id: id, initialState)
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func atomPublisher<Publisher: Combine.Publisher>(
  id: String,
  _ initialState: Publisher
) -> MPublisherAtom<Publisher> {
  MPublisherAtom(id: id, initialState)
}
