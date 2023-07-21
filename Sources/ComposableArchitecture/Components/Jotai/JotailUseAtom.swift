import Foundation
import Combine
import SwiftUI

/// Primitve and flexible useAtom

// MARK: UseAtom
public func useAtom<State>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) -> State
) -> Binding<State> {
  let atom: MStateAtom = atom(id: id, initialState)
  return useRecoilState(atom)
}

public func useAtom<State>(
  id: String,
  _ initialState: State
) -> Binding<State> {
  let atom: MStateAtom = atom(id: id, initialState)
  return useRecoilState(atom)
}

@MainActor
public func useAtom<V>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) -> V
) -> V {
  let atom: MValueAtom = atom(id: id, initialState)
  return useRecoilValue(atom)
}

@MainActor
public func useAtom<V>(
  id: String,
  _ initialState: V
) -> V {
  let atom: MValueAtom = atom(id: id, initialState)
  return useRecoilValue(atom)
}

public func useAtom<V>(
  id: String,
  _ initialState: @escaping () async -> V
) -> AsyncPhase<V, Never> {
  let atom: MTaskAtom = atom(id: id, initialState)
  return useRecoilTask(.once, atom)
}

public func useAtom<V>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) async -> V
) -> AsyncPhase<V, Never> {
  let atom: MTaskAtom = atom(id: id, initialState)
  return useRecoilTask(.once, atom)
}

public func useAtom<V>(
  id: String,
  _ initialState: @escaping () async throws -> V
) -> AsyncPhase<V, Error> {
  let atom: MThrowingTaskAtom = atom(id: id, initialState)
  return useRecoilThrowingTask(.once, atom)
}

public func useAtom<V>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) async throws -> V
) -> AsyncPhase<V, Error> {
  let atom: MThrowingTaskAtom = atom(id: id, initialState)
  return useRecoilThrowingTask(.once, atom)
}

public func useAtom<Publisher: Combine.Publisher>(
  id: String,
  _ initialState: Publisher
) -> AsyncPhase<Publisher.Output, Publisher.Failure> {
  let atom: MPublisherAtom = atom(id: id, initialState)
  return useRecoilPublisher(atom)
}

public func useAtom<Publisher: Combine.Publisher>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) -> Publisher
) -> AsyncPhase<Publisher.Output, Publisher.Failure> {
  let atom: MPublisherAtom = atom(id: id, initialState)
  return useRecoilPublisher(atom)
}
