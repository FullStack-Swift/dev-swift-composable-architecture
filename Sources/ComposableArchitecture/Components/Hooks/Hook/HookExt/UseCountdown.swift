import Foundation
import SwiftUI
import Combine

/// Description
/// Create countdown timers using useCountdown.
/// The useCountdown hook is useful for creating a countdown timer.
/// By specifying an endTime and various options such as the interval between ticks and callback functions for each tick and completion,
/// the hook sets up an interval that updates the count and triggers the appropriate callbacks until the countdown reaches zero.
/// The countdown value is returned, allowing you to easily incorporate and display the countdown in your components.
/// - Parameters:
///   - countdown: The current count of the countdown.
///   - withTimeInterval: The number of seconds between firings of the timer. If seconds is less than or equal to 0.0, this method chooses the nonnegative value of 0.1 milliseconds instead
/// - Returns: TimerHook
public func useCountdown(
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
    cancel: {
      phase.wrappedValue = .cancel
      count.wrappedValue = countdown
      isAutoCountdown.wrappedValue = false
    },
    phase: phase
  )
}

public struct TimerHook {
  public let value: Binding<Double>
  public let isAutoCountdown: Binding<Bool>
  public var start: () -> ()
  public var stop: () -> ()
  public var play: () -> ()
  public var cancel: () -> ()
  public var phase: Binding<TimerPhase>
}

extension TimerHook {
  public enum TimerPhase: Equatable {
    case pending
    case start(Double)
    case stop
    case cancel
    case process(Double)
    case completion
  }
}
