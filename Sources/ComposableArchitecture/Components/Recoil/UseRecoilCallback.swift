import Foundation

public typealias RecoilCallback<R> = (RecoilGlobalContext) -> R

public typealias RecoilAsyncCallback<R> = (RecoilGlobalContext) async -> R

public typealias RecoilThrowingAsyncCallback<R> = (RecoilGlobalContext) async throws -> R

public typealias ParamRecoilCallback<Param, R> = (Param, RecoilGlobalContext) -> R

public typealias ParamRecoilAsyncCallback<Param, R> = (Param, RecoilGlobalContext) async -> R

public typealias ParamRecoilThrowingAsyncCallback<Param, R> = (Param, RecoilGlobalContext) async throws -> R

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@discardableResult
@MainActor
public func useRecoilCallback<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ updateStrategy: HookUpdateStrategy? = .once,
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
public func useRecoilCallback<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ fn: @escaping RecoilAsyncCallback<Node>
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

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@discardableResult
@MainActor
public func useRecoilCallback<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ fn: @escaping RecoilThrowingAsyncCallback<Node>
) -> ThrowingAsyncCallback<Node> {
  useHook(
    UseRecoilThrowingAsyncCallBackHook(
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
public func useRecoilLayoutCallback<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ updateStrategy: HookUpdateStrategy? = .once,
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

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@discardableResult
@MainActor
public func useRecoilLayoutCallback<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ updateStrategy: HookUpdateStrategy? = .once,
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

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@discardableResult
@MainActor
public func useRecoilLayoutCallback<Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ fn: @escaping RecoilThrowingAsyncCallback<Node>
) -> ThrowingAsyncCallback<Node> {
  useHook(
    UseRecoilThrowingAsyncCallBackHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: false,
      fn: fn,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

private struct UseRecoilCallBackHook<Node>: Hook {
  
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

private struct UseRecoilAsyncCallBackHook<Node>: Hook {
  
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
      await (coordinator.state.fn ?? fn)(coordinator.state.context)
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

private struct UseRecoilThrowingAsyncCallBackHook<Node>: Hook {
  
  typealias State = _RecoilHookRef
  
  let updateStrategy: HookUpdateStrategy?
  
  let shouldDeferredUpdate: Bool
  
  let fn: RecoilThrowingAsyncCallback<Node>
  
  var location: SourceLocation
  
  @MainActor
  func makeState() -> State {
    State(location: location)
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> ThrowingAsyncCallback<Node> {
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

private extension UseRecoilThrowingAsyncCallBackHook {
  // MARK: State
  @MainActor
  final class _RecoilHookRef {
    
    var _context: RecoilGlobalViewContext
    
    var context: RecoilGlobalContext
    
    var fn: RecoilThrowingAsyncCallback<Node>?
    
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

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@discardableResult
@MainActor
public func useParamRecoilCallback<Param, Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ fn: @escaping ParamRecoilCallback<Param, Node>
) -> ParamCallback<Param, Node> {
  useHook(
    UseParamRecoilCallBackHook(
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
public func useParamRecoilCallback<Param, Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ fn: @escaping ParamRecoilAsyncCallback<Param, Node>
) -> ParamAsyncCallback<Param, Node> {
  useHook(
    UseParamRecoilAsyncCallBackHook(
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
public func useParamRecoilCallback<Param, Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ fn: @escaping ParamRecoilThrowingAsyncCallback<Param, Node>
) -> ParamThrowingAsyncCallback<Param, Node> {
  useHook(
    UseParamRecoilThrowingAsyncCallBackHook(
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
public func useParamRecoilLayoutCallback<Param, Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ fn: @escaping ParamRecoilCallback<Param, Node>
) -> ParamCallback<Param, Node> {
  useHook(
    UseParamRecoilCallBackHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: false,
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
public func useParamRecoilLayoutCallback<Param, Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ fn: @escaping ParamRecoilAsyncCallback<Param, Node>
) -> ParamAsyncCallback<Param, Node> {
  useHook(
    UseParamRecoilAsyncCallBackHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: false,
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
public func useParamRecoilLayoutCallback<Param, Node>(
  fileID: String = #fileID,
  line: UInt = #line,
  _ updateStrategy: HookUpdateStrategy? = .once,
  _ fn: @escaping ParamRecoilThrowingAsyncCallback<Param, Node>
) -> ParamThrowingAsyncCallback<Param, Node> {
  useHook(
    UseParamRecoilThrowingAsyncCallBackHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: false,
      fn: fn,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

private struct UseParamRecoilCallBackHook<Param, Node>: Hook {
  
  typealias State = _RecoilHookRef
  
  let updateStrategy: HookUpdateStrategy?
  
  let shouldDeferredUpdate: Bool
  
  let fn: ParamRecoilCallback<Param, Node>
  
  var location: SourceLocation
  
  @MainActor
  func makeState() -> State {
    State(location: location)
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> ParamCallback<Param, Node> {
    return { param in
      (coordinator.state.fn ?? fn)(param, coordinator.state.context)
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

private extension UseParamRecoilCallBackHook {
  @MainActor
  final class _RecoilHookRef {
    
    internal var _context: RecoilGlobalViewContext
    
    internal var context: RecoilGlobalContext
    
    var fn: ParamRecoilCallback<Param, Node>?
    
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

private struct UseParamRecoilAsyncCallBackHook<Param, Node>: Hook {
  
  typealias State = _RecoilHookRef
  
  let updateStrategy: HookUpdateStrategy?
  
  let shouldDeferredUpdate: Bool
  
  let fn: ParamRecoilAsyncCallback<Param, Node>
  
  var location: SourceLocation
  
  @MainActor
  func makeState() -> State {
    State(location: location)
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> ParamAsyncCallback<Param, Node> {
    return { param in
      await (coordinator.state.fn ?? fn)(param, coordinator.state.context)
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

private extension UseParamRecoilAsyncCallBackHook {
  // MARK: State
  @MainActor
  final class _RecoilHookRef {
    
    var _context: RecoilGlobalViewContext
    
    var context: RecoilGlobalContext
    
    var fn: ParamRecoilAsyncCallback<Param, Node>?
    
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

private struct UseParamRecoilThrowingAsyncCallBackHook<Param, Node>: Hook {
  
  typealias State = _RecoilHookRef
  
  let updateStrategy: HookUpdateStrategy?
  
  let shouldDeferredUpdate: Bool
  
  let fn: ParamRecoilThrowingAsyncCallback<Param, Node>
  
  var location: SourceLocation
  
  @MainActor
  func makeState() -> State {
    State(location: location)
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> ParamThrowingAsyncCallback<Param, Node> {
    return { param in
      try await (coordinator.state.fn ?? fn)(param, coordinator.state.context)
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

private extension UseParamRecoilThrowingAsyncCallBackHook {
  // MARK: State
  @MainActor
  final class _RecoilHookRef {
    
    var _context: RecoilGlobalViewContext
    
    var context: RecoilGlobalContext
    
    var fn: ParamRecoilThrowingAsyncCallback<Param, Node>?
    
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
