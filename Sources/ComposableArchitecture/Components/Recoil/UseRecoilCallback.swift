import Foundation

public typealias RecoilCallback<R> = (RecoilGlobalContext) -> R

public typealias RecoilAsyncCallback<R> = (RecoilGlobalContext) async throws -> R

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@discardableResult
@MainActor
public func useRecoilCallback<Node: StateAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ fn: @escaping RecoilCallback<Node>
) -> Callback<Node> {
  useHook(
    UseRecoilCallBackHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: true,
      fn: fn,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@discardableResult
@MainActor
public func useRecoilCallback<Node: StateAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ fn: @escaping RecoilAsyncCallback< Node>
) -> AsyncCallback<Node> {
  useHook(
    UseRecoilAsyncCallBackHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: true,
      fn: fn,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

@discardableResult
@MainActor
public func useRecoilLayoutCallback<Node: StateAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ fn: @escaping RecoilCallback<Node>
) -> Callback<Node> {
  useHook(
    UseRecoilCallBackHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: false,
      fn: fn,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

@discardableResult
@MainActor
public func useRecoilLayoutCallback<Node: StateAtom>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ fn: @escaping RecoilAsyncCallback<Node>
) -> AsyncCallback<Node> {
  useHook(
    UseRecoilAsyncCallBackHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: false,
      fn: fn,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

private struct UseRecoilCallBackHook<Node: StateAtom>: Hook {
  
  typealias State = _RecoilHookRef
  
  let updateStrategy: HookUpdateStrategy?
  
  let shouldDeferredUpdate: Bool
  
  let fn: RecoilCallback<Node>
  
  var location: SourceLocation
  
  @MainActor
  func makeState() -> State {
    State(location: location)
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Callback<Node> {
    return {
    (coordinator.state.fn ?? fn)(coordinator.state.context)
    }
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
    coordinator.state.fn = fn
  }
  
  @MainActor
  func dispose(state: State) {
    state.dispose()
  }
}

private extension UseRecoilCallBackHook {
  @MainActor
  final class _RecoilHookRef {
    
    internal var _context: RecoilGlobalViewContext
    
    internal var context: RecoilGlobalContext
    
    var fn: RecoilCallback<Node>?
    
    var isDisposed = false
    
    init(location: SourceLocation) {
      _context = RecoilGlobalViewContext(location: location)
      context = _context.wrappedValue
    }
    
    func dispose() {
      fn = nil
      isDisposed = true
    }

  }
}

private struct UseRecoilAsyncCallBackHook<Node: StateAtom>: Hook {
  
  typealias State = _RecoilHookRef
  
  let updateStrategy: HookUpdateStrategy?
  
  let shouldDeferredUpdate: Bool
  
  let fn: RecoilAsyncCallback<Node>
  
  var location: SourceLocation
  
  @MainActor
  func makeState() -> State {
    State(location: location)
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> AsyncCallback<Node> {
    return {
    try await (coordinator.state.fn ?? fn)(coordinator.state.context)
    }
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
    coordinator.state.fn = fn
  }
  
  @MainActor
  func dispose(state: State) {
    state.dispose()
  }
}

private extension UseRecoilAsyncCallBackHook {
  // MARK: State
  @MainActor
  final class _RecoilHookRef {
    
    var _context: RecoilGlobalViewContext
    
    var context: RecoilGlobalContext
    
    var fn: RecoilAsyncCallback<Node>?
    
    var isDisposed = false
    
    init(location: SourceLocation) {
      _context = RecoilGlobalViewContext(location: location)
      context = _context.wrappedValue
    }
    
    func dispose() {
      fn = nil
      isDisposed = true
    }
  }
}
