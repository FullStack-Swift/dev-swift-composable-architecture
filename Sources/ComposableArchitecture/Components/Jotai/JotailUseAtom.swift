import Foundation
import Combine
import SwiftUI

/// Primitve and flexible useAtom

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func useAtomState<State>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) -> State
) -> Binding<State> {
  let atom: MStateAtom = atomState(id: id, initialState)
  return useRecoilState(atom)
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func useAtomState<State>(
  id: String,
  _ initialState: State
) -> Binding<State> {
  let atom: MStateAtom = atomState(id: id, initialState)
  return useRecoilState(atom)
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func useAtomValue<V>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) -> V
) -> V {
  let atom: MValueAtom = atomValue(id: id, initialState)
  return useRecoilValue(atom)
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func useAtomValue<V>(
  id: String,
  _ initialState: V
) -> V {
  let atom: MValueAtom = atomValue(id: id, initialState)
  return useRecoilValue(atom)
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func useAtomTask<V>(
  id: String,
  _ initialState: @escaping () async -> V
) -> AsyncPhase<V, Never> {
  let atom: MTaskAtom = atomTask(id: id, initialState)
  return useRecoilTask(.once, atom)
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func useAtomTask<V>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) async -> V
) -> AsyncPhase<V, Never> {
  let atom: MTaskAtom = atomTask(id: id, initialState)
  return useRecoilTask(.once, atom)
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func useAtomThrowingTask<V>(
  id: String,
  _ initialState: @escaping () async throws -> V
) -> AsyncPhase<V, Error> {
  let atom: MThrowingTaskAtom = atomThrowingTask(id: id, initialState)
  return useRecoilThrowingTask(.once, atom)
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func useAtomThrowingTask<V>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) async throws -> V
) -> AsyncPhase<V, Error> {
  let atom: MThrowingTaskAtom = atomThrowingTask(id: id, initialState)
  return useRecoilThrowingTask(.once, atom)
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func useAtomPublisher<Publisher: Combine.Publisher>(
  id: String,
  _ initialState: Publisher
) -> AsyncPhase<Publisher.Output, Publisher.Failure> {
  let atom: MPublisherAtom = atomPublisher(id: id, initialState)
  return useRecoilPublisher(atom)
}

/// Description: A hook will subscribe the component to re-render if there are changing in the Recoil state.
/// - Parameters:
///   - fileID: fileID description
///   - line: line description
///   - initialNode: initialState description
/// - Returns: Value from AtomLoader
@MainActor
public func useAtomPublisher<Publisher: Combine.Publisher>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) -> Publisher
) -> AsyncPhase<Publisher.Output, Publisher.Failure> {
  let atom: MPublisherAtom = atomPublisher(id: id, initialState)
  return useRecoilPublisher(atom)
}
