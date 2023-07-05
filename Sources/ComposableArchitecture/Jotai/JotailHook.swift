import Foundation
import Combine
import SwiftUI

/// Primitive and flexible state management

// MARK: Atom
public func atom<State>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) -> State
) -> MValueAtom<State> {
  MValueAtom<State>(id: id) { context in
    initialState(context)
  }
}

public func atom<State>(
  id: String,
  _ initialState: State
) -> MValueAtom<State> {
  MValueAtom(id: id) { _ in
    initialState
  }
}

public func atom<State>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) -> State
) -> MStateAtom<State> {
  MStateAtom<State>(id: id) { context in
    return initialState(context)
  }
}

public func atom<State>(
  id: String,
  _ initialState: State
) -> MStateAtom<State> {
  atom(id: id) { _ in
    initialState
  }
}

public func atom<State>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) async -> State
) -> MTaskAtom<State> {
  MTaskAtom(id: id, initialState)
}

public func atom<State>(
  id: String,
  _ initialState: @escaping () async -> State
) -> MTaskAtom<State> {
  MTaskAtom(id: id, initialState)
}

public func atom<State>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) async throws -> State
) -> MThrowingTaskAtom<State> {
  MThrowingTaskAtom(id: id, initialState)
}


public func atom<State>(
  id: String,
  _ initialState: @escaping () async throws -> State
) -> MThrowingTaskAtom<State> {
  MThrowingTaskAtom(id: id, initialState)
}

public func atom<Publisher: Combine.Publisher>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) -> Publisher
) -> MPublisherAtom<Publisher> {
  MPublisherAtom(id: id, initialState)
}


public func atom<Publisher: Combine.Publisher>(
  id: String,
  _ initialState: Publisher
) -> MPublisherAtom<Publisher> {
  MPublisherAtom(id: id, initialState)
}



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

public func useAtom<V>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) -> V
) -> V {
  let atom: MValueAtom = atom(id: id, initialState)
  return useRecoilValue(atom)
}

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
