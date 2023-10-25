/// A hook to use a side effect function that is called the number of times according to the strategy specified with `updateStrategy`.
/// Optionally the function can be cancelled when this hook is disposed or when the side-effect function is called again.
/// Note that the execution is deferred until after ohter hooks have been updated.
///
///     useInitalDeffered {
///         print("Do side effects")
///     }
///
/// - Parameters:
///   - updateStrategy: A strategy that determines when to re-call the given side effect function.
///   - effect: A closure that typically represents a side-effect.
///             It is able to return a closure that to do something when this hook is unmount from the view or when the side-effect function is called again.
public func useInitalDeffered(
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ inital: @escaping () -> Void
) {
  useInitalDeffered {
    inital
  }
}
/// A hook to use a side effect function that is called the number of times according to the strategy specified with `updateStrategy`.
/// Optionally the function can be cancelled when this hook is disposed or when the side-effect function is called again.
/// Note that the execution is deferred until after ohter hooks have been updated.
///
///     useInitalDeffered {
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
public func useInitalDeffered(
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ inital: @escaping () -> (() -> Void)?
) {
  useHook(
    InitalHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: true,
      inital: inital
    )
  )
}

/// A hook to use a side effect function that is called the number of times according to the strategy specified with `updateStrategy`.
/// Optionally the function can be cancelled when this hook is unmount from the view tree or when the side-effect function is called again.
/// The signature is identical to `useEffect`, but this fires synchronously when the hook is called.
///
///     useInital {
///         print("Do side effects")
///     }
///
/// - Parameters:
///   - updateStrategy: A strategy that determines when to re-call the given side effect function.
///   - effect: A closure that typically represents a side-effect.
///             It is able to return a closure that to do something when this hook is unmount from the view or when the side-effect function is called again.
public func useInital(
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ inital: @escaping () -> Void
) {
  useInital {
    inital
  }
}

/// A hook to use a side effect function that is called the number of times according to the strategy specified with `updateStrategy`.
/// Optionally the function can be cancelled when this hook is unmount from the view tree or when the side-effect function is called again.
/// The signature is identical to `useEffect`, but this fires synchronously when the hook is called.
///
///     useInital {
///         print("Do side effects")
///         return nil
///     }
///
/// - Parameters:
///   - updateStrategy: A strategy that determines when to re-call the given side effect function.
///   - effect: A closure that typically represents a side-effect.
///             It is able to return a closure that to do something when this hook is unmount from the view or when the side-effect function is called again.
public func useInital(
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ inital: @escaping () -> (() -> Void)?
) {
  useHook(
    InitalHook(
      updateStrategy: updateStrategy,
      shouldDeferredUpdate: false,
      inital: inital
    )
  )
}


private struct InitalHook: Hook {
  
  typealias State = _HookRef
  
  let updateStrategy: HookUpdateStrategy?
  
  let shouldDeferredUpdate: Bool
  
  let inital: () -> (() -> Void)?
  
  func makeState() -> State {
    State(inital: inital())
  }
  
  func value(coordinator: Coordinator) {
    
  }
  
  func updateState(coordinator: Coordinator) {
    if coordinator.state.inital != nil && !coordinator.state.isDisposed {
      coordinator.state.inital?()
      coordinator.state.dispose()
    }
  }
  
  func dispose(state: State) {
    state.dispose()
  }
}

private extension InitalHook {
  // MARK: State
  final class _HookRef {
    
    var isDisposed = false
    
    var inital: (() -> Void)?
    
    init(
      isDisposed: Bool = false,
      inital: (() -> Void)? = nil
    ) {
      self.isDisposed = isDisposed
      self.inital = inital
    }
    
    func dispose() {
      isDisposed = true
      inital = nil
    }
  }
}
