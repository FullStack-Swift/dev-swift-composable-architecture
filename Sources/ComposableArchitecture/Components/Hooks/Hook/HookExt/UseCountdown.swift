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
) -> HookCountdownState {
  
  @HState
  var count = countdown
  
  @HState
  var isAutoCountdown = false
  
  @HState
  var phase = HookCountdownState.CountdownPhase.pending
  
  useEffect(.preserved(by: isAutoCountdown)) {
    guard isAutoCountdown else { return nil }
    let timer = Timer.scheduledTimer(
      withTimeInterval: withTimeInterval,
      repeats: true
    ) { _ in
      if count <= 0 {
        phase = .completion
        isAutoCountdown = false
      } else {
        count -= withTimeInterval
        phase = .process(count)
      }
    }
    return timer.invalidate
  }
  
  return HookCountdownState(
    value: $count,
    isAutoCountdown: $isAutoCountdown,
    start: {
      phase = .start(countdown)
      count = countdown
      isAutoCountdown = true
    },
    stop: {
      phase = .stop
      isAutoCountdown = false
    },
    play: {
      isAutoCountdown = true
    },
    cancel: {
      phase = .cancel
      count = countdown
      isAutoCountdown = false
    },
    phase: $phase
  )
}

public struct HookCountdownState {
  public let value: Binding<Double>
  public let isAutoCountdown: Binding<Bool>
  public var start: () -> ()
  public var stop: () -> ()
  public var play: () -> ()
  public var cancel: () -> ()
  public var phase: Binding<CountdownPhase>
}

extension HookCountdownState {
  public enum CountdownPhase: Equatable {
    case pending
    case start(Double)
    case stop
    case cancel
    case process(Double)
    case completion
  }
}

@propertyWrapper
public struct HCountdown {
  
  public var wrappedValue: Double
  
  public var withTimeInterval: Double
  
  public init(
    wrappedValue: Double,
    withTimeInterval: Double
  ) {
    self.wrappedValue = wrappedValue
    self.withTimeInterval = withTimeInterval
  }
  
  public var projectedValue: Self {
    self
  }
  
  public var value: HookCountdownState {
    useCountdown(
      countdown: wrappedValue,
      withTimeInterval: withTimeInterval
    )
  }
}
