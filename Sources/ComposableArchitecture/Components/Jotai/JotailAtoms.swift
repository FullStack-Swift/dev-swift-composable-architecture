import Foundation
import Combine
import SwiftUI

/// Primitive and flexible state management

// MARK: Atom
public func atomValue<State>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) -> State
) -> MValueAtom<State> {
  MValueAtom<State>(id: id) { context in
    initialState(context)
  }
}

public func atomValue<State>(
  id: String,
  _ initialState: State
) -> MValueAtom<State> {
  MValueAtom(id: id) { _ in
    initialState
  }
}

public func atomState<State>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) -> State
) -> MStateAtom<State> {
  MStateAtom<State>(id: id) { context in
    return initialState(context)
  }
}

public func atomState<State>(
  id: String,
  _ initialState: State
) -> MStateAtom<State> {
  MStateAtom<State>(id: id) { _ in
    initialState
  }
}

public func atomTask<State>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) async -> State
) -> MTaskAtom<State> {
  MTaskAtom(id: id, initialState)
}

public func atomTask<State>(
  id: String,
  _ initialState: @escaping () async -> State
) -> MTaskAtom<State> {
  MTaskAtom(id: id, initialState)
}

public func atomThrowingTask<State>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) async throws -> State
) -> MThrowingTaskAtom<State> {
  MThrowingTaskAtom(id: id, initialState)
}


public func atomThrowingTask<State>(
  id: String,
  _ initialState: @escaping () async throws -> State
) -> MThrowingTaskAtom<State> {
  MThrowingTaskAtom(id: id, initialState)
}

public func atomPublisher<Publisher: Combine.Publisher>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) -> Publisher
) -> MPublisherAtom<Publisher> {
  MPublisherAtom(id: id, initialState)
}


public func atomPublisher<Publisher: Combine.Publisher>(
  id: String,
  _ initialState: Publisher
) -> MPublisherAtom<Publisher> {
  MPublisherAtom(id: id, initialState)
}
