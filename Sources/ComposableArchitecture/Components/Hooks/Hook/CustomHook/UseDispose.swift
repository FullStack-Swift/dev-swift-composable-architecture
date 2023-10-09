/// A hook to use a side effect function that is called the number of times according to the strategy specified with `updateStrategy`.
/// Optionally the function can be cancelled when this hook is disposed or when the side-effect function is called again.
/// Note that the execution is deferred until after ohter hooks have been updated.
///
///     useDisposeDeffered {
///         print("Do side effects")
///     }
///
/// - Parameters:
///   - updateStrategy: A strategy that determines when to re-call the given side effect function.
///   - effect: A closure that typically represents a side-effect.
///             It is able to return a closure that to do something when this hook is unmount from the view or when the side-effect function is called again.
public func useDisposeDeffered(
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ effect: @escaping () -> Void
) {
  useDisposeDeffered {
    effect
  }
}

/// A hook to use a side effect function that is called the number of times according to the strategy specified with `updateStrategy`.
/// Optionally the function can be cancelled when this hook is disposed or when the side-effect function is called again.
/// Note that the execution is deferred until after ohter hooks have been updated.
///
///     useDisposeDeffered {
///         print("Do side effects")
///
///         return {
///             print("Do cleanup")
///         }
///     }
///
/// - Parameters:
///   - updateStrategy: A strategy that determines when to re-call the given side effect function.
///   - effect: A closure that typically represents a side-effect.
///             It is able to return a closure that to do something when this hook is unmount from the view or when the side-effect function is called again.
public func useDisposeDeffered(
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ effect: @escaping () -> (() -> Void)?
) {
  useHook(
    UseDispose(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: true,
      effect: effect
    )
  )
}

/// A hook to use a side effect function that is called the number of times according to the strategy specified with `updateStrategy`.
/// Optionally the function can be cancelled when this hook is unmount from the view tree or when the side-effect function is called again.
/// The signature is identical to `useEffect`, but this fires synchronously when the hook is called.
///
///     useDispose {
///         print("Do side effects")
///     }
///
/// - Parameters:
///   - updateStrategy: A strategy that determines when to re-call the given side effect function.
///   - effect: A closure that typically represents a side-effect.
///             It is able to return a closure that to do something when this hook is unmount from the view or when the side-effect function is called again.
public func useDispose(
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ effect: @escaping () -> Void
) {
  useDispose {
    effect
  }
}

/// A hook to use a side effect function that is called the number of times according to the strategy specified with `updateStrategy`.
/// Optionally the function can be cancelled when this hook is unmount from the view tree or when the side-effect function is called again.
/// The signature is identical to `useEffect`, but this fires synchronously when the hook is called.
///
///     useDispose {
///         print("Do side effects")
///         return nil
///     }
///
/// - Parameters:
///   - updateStrategy: A strategy that determines when to re-call the given side effect function.
///   - effect: A closure that typically represents a side-effect.
///             It is able to return a closure that to do something when this hook is unmount from the view or when the side-effect function is called again.
public func useDispose(
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ effect: @escaping () -> (() -> Void)?
) {
  useHook(
    UseDispose(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: false,
      effect: effect
    )
  )
}

private struct UseDispose: Hook {
  
  typealias State = _HookRef
  
  let updateStrategy: HookUpdateStrategy?
  
  let shouldDeferredUpdate: Bool
  
  let effect: () -> (() -> Void)?
  
  func makeState() -> State {
    State(cleanup: effect())
  }
  
  func value(coordinator: Coordinator) {
    
  }
  
  func updateState(coordinator: Coordinator) {
    if coordinator.state.cleanup != nil && !coordinator.state.isDisposed {
      coordinator.state.cleanup = effect()
    }
  }
  
  func dispose(state: State) {
    state.dispose()
  }
}

private extension UseDispose {
  final class _HookRef {
    
    var isDisposed = false
    
    var cleanup: (() -> Void)?
    
    init(
      isDisposed: Bool = false,
      cleanup: (() -> Void)? = nil
    ) {
      self.isDisposed = isDisposed
      self.cleanup = cleanup
    }
    
    func dispose() {
      isDisposed = true
      cleanup?()
      cleanup = nil
    }
  }
}
