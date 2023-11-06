// MARK: useOnceExistedPhaseStatusPending

/// Get Once Exist-ed Status `pending` from `AsyncPhase` where status is Success, with other status, it will return preview Success.
///
///       let phase: AsyncPhase<Success, Error> = ...
///       let value = useOnceExistedPhaseStatusPending(phase)
///
/// - Parameter phase: phase to get value.
/// - Returns: Success Value from AsyncPhase
public func useOnceExistedPhaseStatusPending<Success, Failure>(
  _ phase: AsyncPhase<Success, Failure>
) -> AsyncPhase<Success, Failure>.StatusPhase? {
  useOnceExistedPhaseStatus(status: .pending, phase)
}

// MARK: useOnceExistedPhaseStatusRunning

/// Get Only Value from `AsyncPhase` where status is Success, with other status, it will return preview Success.
///
///       let phase: AsyncPhase<Success, Error> = ...
///       let value = useOnceExistedPhaseStatusRunning(phase)
///
/// - Parameter phase: phase to get value.
/// - Returns: Success Value from AsyncPhase
public func useOnceExistedPhaseStatusRunning<Success, Failure>(
  _ phase: AsyncPhase<Success, Failure>
) -> AsyncPhase<Success, Failure>.StatusPhase? {
  useOnceExistedPhaseStatus(status: .running, phase)
}

// MARK: useOnceExistedPhaseStatusSuccess

/// Get Only Value from `AsyncPhase` where status is Success, with other status, it will return preview Success.
///
///       let phase: AsyncPhase<Success, Error> = ...
///       let value = useOnceExistedPhaseStatusSuccess(phase)
///
/// - Parameter phase: phase to get value.
/// - Returns: Success Value from AsyncPhase
public func useOnceExistedPhaseStatusSuccess<Success, Failure>(
  _ phase: AsyncPhase<Success, Failure>
) -> AsyncPhase<Success, Failure>.StatusPhase? {
  useOnceExistedPhaseStatus(status: .success, phase)
}

// MARK: useOnceExistedPhaseStatusFailure

/// Get Only Value from `AsyncPhase` where status is Success, with other status, it will return preview Success.
///
///       let phase: AsyncPhase<Success, Error> = ...
///       let value = useOnceExistedPhaseStatusFailure(phase)
///
/// - Parameter phase: phase to get value.
/// - Returns: Success Value from AsyncPhase
public func useOnceExistedPhaseStatusFailure<Success, Failure>(
  _ phase: AsyncPhase<Success, Failure>
) -> AsyncPhase<Success, Failure>.StatusPhase? {
  useOnceExistedPhaseStatus(status: .failure, phase)
}

// MARK: useOnceExistedPhaseStatus

/// Get Only Value from `AsyncPhase` where status is Success, with other status, it will return preview Success.
///
///       let phase: AsyncPhase<Success, Error> = ...
///       let value = useOnceExistedPhaseStatus(status:..., phase)
///
/// - Parameter phase: phase to get value.
/// - Returns: Success Value from AsyncPhase
public func useOnceExistedPhaseStatus<Success, Failure>(
  status: AsyncPhase<Success, Failure>.StatusPhase,
  _ phase: AsyncPhase<Success, Failure>
) -> AsyncPhase<Success, Failure>.StatusPhase? {
  let ref = useRef(nil as AsyncPhase<Success, Failure>.StatusPhase?)
  useMemo(.preserved(by: phase.status)) {
    if ref.current == status {
      return
    }
    if phase.status == status {
      ref.current = status
    }
  }
  return ref.current
}
