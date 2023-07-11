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
  let _countdown = countdown + 1
  let count = useState(_countdown)
  let isIncrement = useState(false)
  let phase = useState(TimerHook.TimerPhase.pending)
  useEffect(.preserved(by: isIncrement.wrappedValue)) {
    guard isIncrement.wrappedValue else { return nil }
    let timer = Timer.scheduledTimer(withTimeInterval: withTimeInterval, repeats: true) { _ in
      if count.wrappedValue <= 0 {
        phase.wrappedValue = .completion
        isIncrement.wrappedValue = false
      } else {
        count.wrappedValue -= withTimeInterval
        phase.wrappedValue = .process(count.wrappedValue)
      }
    }
    return timer.invalidate
  }
  
  return TimerHook(
    count: count,
    isIncrement: isIncrement,
    start: {
      phase.wrappedValue = .start(countdown)
      count.wrappedValue = countdown
      isIncrement.wrappedValue = true
    },
    stop: {
      phase.wrappedValue = .stop
      isIncrement.wrappedValue = false
    },
    play: {
      isIncrement.wrappedValue = true
    },
    canncel: {
      phase.wrappedValue = .cancel
      count.wrappedValue = countdown
      isIncrement.wrappedValue = false
    },
    phase: phase
  )
}

public struct TimerHook {
  
  public enum TimerPhase {
    case pending
    case start(Double)
    case stop
    case cancel
    case process(Double)
    case completion
  }
  
  public let count: Binding<Double>
  public let isIncrement: Binding<Bool>
  public var start: () -> ()
  public var stop: () -> ()
  public var play: () -> ()
  public var canncel: () -> ()
  public var phase: Binding<TimerPhase>
}
