import Foundation

public typealias RecoilCallback<R> = (RecoilGlobalContext) -> R

public typealias RecoilAsyncCallback<R> = (RecoilGlobalContext) async throws -> R

@discardableResult
@MainActor public func useRecoilCallback<Node: StateAtom>(
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ fn: @escaping RecoilCallback<Node>
) -> Callback<Node> {
  useHook(
    UseRecoilCallBackHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: true,
      fn: fn
    )
  )
}

@discardableResult
@MainActor public func useRecoilCallback<Node: StateAtom>(
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ fn: @escaping RecoilAsyncCallback< Node>
) -> AsyncCallback<Node> {
  useHook(
    UseRecoilAsyncCallBackHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: true,
      fn: fn
    )
  )
}

@discardableResult
@MainActor public func useRecoilLayoutCallback<Node: StateAtom>(
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ fn: @escaping RecoilCallback<Node>
) -> Callback<Node> {
  useHook(
    UseRecoilCallBackHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: false,
      fn: fn
    )
  )
}

@discardableResult
@MainActor public func useRecoilLayoutCallback<Node: StateAtom>(
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ fn: @escaping RecoilAsyncCallback<Node>
) -> AsyncCallback<Node> {
  useHook(
    UseRecoilAsyncCallBackHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: false,
      fn: fn
    )
  )
}

private struct UseRecoilCallBackHook<Node: StateAtom>: Hook {
  let updateStrategy: HookUpdateStrategy?
  let shouldDeferredUpdate: Bool
  let fn: RecoilCallback<Node>
  
  @MainActor
  func makeState() -> State {
    State()
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Callback<Node> {
    return {
    (coordinator.state.fn ?? fn)(coordinator.state.context)
    }
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    coordinator.state.fn = fn
  }
  
  @MainActor
  func dispose(state: State) {
    state.fn = nil
  }
}

private extension UseRecoilCallBackHook {
  final class State {
    
    @RecoilGlobalViewContext
    var context

    var fn: RecoilCallback<Node>?
  }
}

private struct UseRecoilAsyncCallBackHook<Node: StateAtom>: Hook {
  let updateStrategy: HookUpdateStrategy?
  let shouldDeferredUpdate: Bool
  let fn: RecoilAsyncCallback<Node>
  
  @MainActor
  func makeState() -> State {
    State()
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> AsyncCallback<Node> {
    return {
    try await (coordinator.state.fn ?? fn)(coordinator.state.context)
    }
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    coordinator.state.fn = fn
  }
  
  @MainActor
  func dispose(state: State) {
    state.fn = nil
  }
}

private extension UseRecoilAsyncCallBackHook {
  final class State {
    
    @RecoilGlobalViewContext
    var context

    var fn: RecoilAsyncCallback<Node>?
  }
}
