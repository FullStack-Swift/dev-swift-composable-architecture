import Foundation
import Combine
import SwiftUI

/// Primitve and flexible useAtom

// MARK: UseAtom
public func useAtomState<State>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) -> State
) -> Binding<State> {
  let atom: MStateAtom = atomState(id: id, initialState)
  return useRecoilState(atom)
}

public func useAtomState<State>(
  id: String,
  _ initialState: State
) -> Binding<State> {
  let atom: MStateAtom = atomState(id: id, initialState)
  return useRecoilState(atom)
}

@MainActor
public func useAtomValue<V>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) -> V
) -> V {
  let atom: MValueAtom = atomValue(id: id, initialState)
  return useRecoilValue(atom)
}

@MainActor
public func useAtomValue<V>(
  id: String,
  _ initialState: V
) -> V {
  let atom: MValueAtom = atomValue(id: id, initialState)
  return useRecoilValue(atom)
}

public func useAtomTask<V>(
  id: String,
  _ initialState: @escaping () async -> V
) -> AsyncPhase<V, Never> {
  let atom: MTaskAtom = atomTask(id: id, initialState)
  return useRecoilTask(.once, atom)
}

public func useAtomTask<V>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) async -> V
) -> AsyncPhase<V, Never> {
  let atom: MTaskAtom = atomTask(id: id, initialState)
  return useRecoilTask(.once, atom)
}

public func useAtomThrowingTask<V>(
  id: String,
  _ initialState: @escaping () async throws -> V
) -> AsyncPhase<V, Error> {
  let atom: MThrowingTaskAtom = atomThrowingTask(id: id, initialState)
  return useRecoilThrowingTask(.once, atom)
}

public func useAtomThrowingTask<V>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) async throws -> V
) -> AsyncPhase<V, Error> {
  let atom: MThrowingTaskAtom = atomThrowingTask(id: id, initialState)
  return useRecoilThrowingTask(.once, atom)
}

public func useAtomPublisher<Publisher: Combine.Publisher>(
  id: String,
  _ initialState: Publisher
) -> AsyncPhase<Publisher.Output, Publisher.Failure> {
  let atom: MPublisherAtom = atomPublisher(id: id, initialState)
  return useRecoilPublisher(atom)
}

public func useAtomPublisher<Publisher: Combine.Publisher>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) -> Publisher
) -> AsyncPhase<Publisher.Output, Publisher.Failure> {
  let atom: MPublisherAtom = atomPublisher(id: id, initialState)
  return useRecoilPublisher(atom)
}
