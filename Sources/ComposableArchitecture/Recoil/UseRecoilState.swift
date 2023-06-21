import SwiftUI

// MARK: useRecoilState
@MainActor public func useRecoilState<Node: StateAtom>(
  _ initialState: Node,
  context: AtomViewContext
) -> Binding<Node.Loader.Value> {
  useRecoilState({initialState}, context: context)
}

// MARK: useRecoilState
@MainActor public func useRecoilState<Node: StateAtom>(
  _ initialState: @escaping() -> Node,
  context: AtomViewContext
) -> Binding<Node.Loader.Value> {
  useHook(RecoilStateHook<Node>(initialState: initialState, context: context))
}

private struct RecoilStateHook<Node: StateAtom>: Hook {
  let initialState: () -> Node
  let updateStrategy: HookUpdateStrategy? = .once

  let context: AtomViewContext

  func makeState() -> Ref {
    Ref(initialState: initialState())
  }

  init(initialState: @escaping () -> Node, context: AtomViewContext) {
    self.initialState = initialState
    self.context = context
  }

  @MainActor
  func value(coordinator: Coordinator) -> Binding<Node.Loader.Value> {
    context.state(coordinator.state.state)
  }

  func dispose(state: Ref) {
    state.isDisposed = true
  }
}

private extension RecoilStateHook {
  final class Ref {
    var state: Node
    var isDisposed = false

    init(initialState: Node) {
      self.state = initialState
    }
  }
}

