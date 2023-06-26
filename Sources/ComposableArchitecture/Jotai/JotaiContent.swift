import Foundation
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

// MARK: UseAtom
public func useAtom<State>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) -> State
) -> Binding<State> {
  let atom: MStateAtom = atom(id: id, initialState)
  return useHook(JotaiStateHook<State>(initialState: {atom}))
}

public func useAtom<State>(
  id: String,
  _ initialState: State
) -> Binding<State> {
  let atom: MStateAtom = atom(id: id, initialState)
  return useHook(JotaiStateHook<State>(initialState: {atom}))
}

public func useAtom<V>(
  id: String,
  _ initialState: @escaping (AtomTransactionContext<Void>) -> V
) -> V {
  let atom: MValueAtom = atom(id: id, initialState)
  return useHook(JotaiValueHook<V>(initialState: {atom}))
}

public func useAtom<V>(
  id: String,
  _ initialState: V
) -> V {
  let atom: MValueAtom = atom(id: id, initialState)
  return useHook(JotaiValueHook<V>(initialState: {atom}))
}


// MARK: Jotai + Hook
private struct JotaiValueHook<V>: Hook {
  typealias Value = V

  let initialState: () -> MValueAtom<V>
  let updateStrategy: HookUpdateStrategy? = .once

  @MainActor
  func makeState() -> State {
    State(initialState: initialState())
  }

  @MainActor
  func value(coordinator: Coordinator) -> Value {
    coordinator.state.value
  }

  @MainActor
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
  }

  @MainActor
  func dispose(state: State) {
    state.isDisposed = true
  }

}

private extension JotaiValueHook {
  // MARK: State
  final class State {

    @RecoilViewContext
    var context

    var node: MValueAtom<V>
    var isDisposed = false

    init(initialState: MValueAtom<V>) {
      self.node = initialState
    }

    /// Get current value from Recoilcontext
    @MainActor
    var value: Value {
      context.watch(node)
    }
  }
}

private struct JotaiStateHook<State>: Hook {
  let initialState: () -> MStateAtom<State>
  var updateStrategy: HookUpdateStrategy? = .once

  @MainActor
  func makeState() -> Ref {
    Ref(initialState: initialState())
  }

  @MainActor
  func value(coordinator: Coordinator) -> Binding<State> {
    Binding(
      get: {
        coordinator.state.context.watch(coordinator.state.state)
      },
      set: { newState, transaction in
        assertMainThread()

        guard !coordinator.state.isDisposed else {
          return
        }

        withTransaction(transaction) {
          coordinator.state.context.set(newState, for: coordinator.state.state)
          coordinator.updateView()
        }
      }
    )
  }

  @MainActor
  func dispose(state: Ref) {
    state.isDisposed = true
  }
}

private extension JotaiStateHook {
  final class Ref {

    @RecoilViewContext
    var context

    var state: MStateAtom<State>
    var isDisposed = false

    init(initialState: MStateAtom<State>) {
      state = initialState
    }

    /// Get current value from Recoilcontext
    var value: Binding<State> {
      context.state(state)
    }
  }
}
