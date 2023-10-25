// MARK: useNextPhaseValue

/// Get Only Value from `HookAsyncPhase` where status is Success, with other status, it will return preview Success.
///
///       let phase: HookAsyncPhase<Success, Error> = ...
///       let value = useNextPhaseValue(phase)
///
/// - Parameter phase: phase to get value.
/// - Returns: Success Value from HookAsyncPhase
public func useNextPhaseValue<Success, Failure>(
  _ phase: HookAsyncPhase<Success, Failure>
) -> Success? {
  let ref = useRef(phase.value)
  useLayoutEffect {
    if let value = phase.value {
      ref.current = value
    }
    return nil
  }
  return ref.current
}

// MARK: useNextPhaseFailure

/// Get Only Failure from `HookAsyncPhase` where status is Failure, with other status, it will return preview Failure.
///
///       let phase: HookAsyncPhase<Success, Error> = ...
///       let failure = useNextPhaseFailure(phase)
///
/// - Parameter phase: phase to get value.
/// - Returns: Failure Value from HookAsyncPhase
public func useNextPhaseFailure<Success, Failure>(
  _ phase: HookAsyncPhase<Success, Failure>
) -> Failure? {
  let ref = useRef(phase.error)
  useLayoutEffect {
    if let error = phase.error {
      ref.current = error
    }
    return nil
  }
  return ref.current
}

// MARK: useNextPhaseResult

/// Get Only Result from `HookAsyncPhase` where status is success or failure, with other status, it will return preview Result.
///
///       let phase: HookAsyncPhase<Success, Error> = ...
///       let result = useNextPhaseResult(phase)
///
/// - Parameter phase: phase to get value.
/// - Returns: Success Value from HookAsyncPhase
public func useNextPhaseResult<Success, Failure>(
  _ phase: HookAsyncPhase<Success, Failure>
) -> Result<Success, Failure>? {
  let ref = useRef(phase.result)
  useLayoutEffect {
    if let result = phase.result {
      ref.current = result
    }
    return nil
  }
  return ref.current
}

// MARK: useNextPhaseTaskResult

/// Get Only Value from `HookAsyncPhase` where status is success or failure, with other status, it will return preview TaskResult.
///
///       let phase: HookAsyncPhase<Success, Error> = ...
///       let value = useNextPhaseTaskResult(phase)
///
/// - Parameter phase: phase to get value.
/// - Returns: Success Value from HookAsyncPhase
public func useNextPhaseTaskResult<Success, Failure>(
  _ phase: HookAsyncPhase<Success, Failure>
) -> TaskResult<Success>? {
  let ref = useRef(phase.taskResult)
  useLayoutEffect {
    if let taskResult = phase.taskResult {
      ref.current = taskResult
    }
    return nil
  }
  return ref.current
}
