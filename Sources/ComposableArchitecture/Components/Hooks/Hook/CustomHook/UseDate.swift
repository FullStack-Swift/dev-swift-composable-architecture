import Foundation

/// Description
/// - Returns: Date
public func useDate() -> Date? {
  let phase = usePublisher(.once) {
    Timer.publish(every: 1, on: .main, in: .common)
      .autoconnect()
      .prepend(Date())
  }
  return phase.value
}

/// Description
/// - Parameter date: date description
/// - Returns: Date
public func useDate(date: Date) -> Date? {
  let phase = usePublisher(.once) {
    Timer.publish(every: 1, on: .main, in: .common)
      .autoconnect()
      .prepend(date)
  }
  return phase.value
}

/// Description
/// - Returns: AsyncPhase
public func usePhaseDate() -> HookAsyncPhase<Date, Never> {
  usePublisher(.once) {
    Timer.publish(every: 1, on: .main, in: .common)
      .autoconnect()
      .prepend(Date())
  }
}
