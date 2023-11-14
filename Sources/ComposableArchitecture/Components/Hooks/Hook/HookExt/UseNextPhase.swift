// MARK: useNextPhaseValue

/// Get Only Value from `AsyncPhase` where status is Success, with other status, it will return preview Success.
///
///       let phase: AsyncPhase<Success, Error> = ...
///       let value = useNextPhaseValue(phase)
///
/// - Parameter phase: phase to get value.
/// - Returns: Success Value from AsyncPhase
public func useNextPhaseValue<Success, Failure>(
  _ phase: AsyncPhase<Success, Failure>
) -> Success? {
  @HRef
  var ref = phase.value
  useLayoutEffect(.preserved(by: phase.status)) {
    if let value = phase.value {
      ref = value
    }
    return nil
  }
  return ref
}

// MARK: useNextPhaseFailure

/// Get Only Failure from `AsyncPhase` where status is Failure, with other status, it will return preview Failure.
///
///       let phase: AsyncPhase<Success, Error> = ...
///       let failure = useNextPhaseFailure(phase)
///
/// - Parameter phase: phase to get value.
/// - Returns: Failure Value from AsyncPhase
public func useNextPhaseFailure<Success, Failure>(
  _ phase: AsyncPhase<Success, Failure>
) -> Failure? {
  @HRef
  var ref = phase.error
  useLayoutEffect(.preserved(by: phase.status)) {
    if let error = phase.error {
      ref = error
    }
    return nil
  }
  return ref
}

// MARK: useNextPhaseResult

/// Get Only Result from `AsyncPhase` where status is success or failure, with other status, it will return preview Result.
///
///       let phase: AsyncPhase<Success, Error> = ...
///       let result = useNextPhaseResult(phase)
///
/// - Parameter phase: phase to get value.
/// - Returns: Success Value from AsyncPhase
public func useNextPhaseResult<Success, Failure>(
  _ phase: AsyncPhase<Success, Failure>
) -> Result<Success, Failure>? {
  @HRef
  var ref = phase.result
  useLayoutEffect(.preserved(by: phase.status)) {
    if let result = phase.result {
      ref = result
    }
    return nil
  }
  return ref
}

// MARK: useNextPhaseTaskResult

/// Get Only Value from `AsyncPhase` where status is success or failure, with other status, it will return preview TaskResult.
///
///       let phase: AsyncPhase<Success, Error> = ...
///       let value = useNextPhaseTaskResult(phase)
///
/// - Parameter phase: phase to get value.
/// - Returns: Success Value from AsyncPhase
public func useNextPhaseTaskResult<Success, Failure>(
  _ phase: AsyncPhase<Success, Failure>
) -> TaskResult<Success>? {
  @HRef
  var ref = phase.taskResult
  useLayoutEffect(.preserved(by: phase.status)) {
    if let taskResult = phase.taskResult {
      ref = taskResult
    }
    return nil
  }
  return ref
}
