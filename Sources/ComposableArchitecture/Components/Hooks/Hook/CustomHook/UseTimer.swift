import Foundation
import SwiftUI
import Combine

/// Description
/// using useState, useEffect.
/// - Parameters:
///   - countdown: countdown description
///   - withTimeInterval: withTimeInterval description
/// - Returns: TimerHook
public func useCountDownTimer(
  countdown: Double,
  withTimeInterval: TimeInterval = 0.1
) -> TimerHook {
  let count = useState(countdown)
  let isAutoCountdown = useState(false)
  let phase = useState(TimerHook.TimerPhase.pending)
  useEffect(.preserved(by: isAutoCountdown.wrappedValue)) {
    guard isAutoCountdown.wrappedValue else { return nil }
    let timer = Timer.scheduledTimer(withTimeInterval: withTimeInterval, repeats: true) { _ in
      if count.wrappedValue <= 0 {
        phase.wrappedValue = .completion
        isAutoCountdown.wrappedValue = false
      } else {
        count.wrappedValue -= withTimeInterval
        phase.wrappedValue = .process(count.wrappedValue)
      }
    }
    return timer.invalidate
  }
  
  return TimerHook(
    value: count,
    isAutoCountdown: isAutoCountdown,
    start: {
      phase.wrappedValue = .start(countdown)
      count.wrappedValue = countdown
      isAutoCountdown.wrappedValue = true
    },
    stop: {
      phase.wrappedValue = .stop
      isAutoCountdown.wrappedValue = false
    },
    play: {
      isAutoCountdown.wrappedValue = true
    },
    canncel: {
      phase.wrappedValue = .cancel
      count.wrappedValue = countdown
      isAutoCountdown.wrappedValue = false
    },
    phase: phase
  )
}

public struct TimerHook {
  
  public enum TimerPhase: Equatable {
    case pending
    case start(Double)
    case stop
    case cancel
    case process(Double)
    case completion
  }
  
  public let value: Binding<Double>
  public let isAutoCountdown: Binding<Bool>
  public var start: () -> ()
  public var stop: () -> ()
  public var play: () -> ()
  public var canncel: () -> ()
  public var phase: Binding<TimerPhase>
}
