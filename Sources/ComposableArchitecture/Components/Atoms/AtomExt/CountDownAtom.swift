import Combine
import SwiftUI
///
///   Countdown with ObservableObject, It's class for countdown using Timer.
///
///    What you can do with class:
///    1: - start function when you want start timer.
///    2: - stop function when you want stop countdown timer.
///    3: - play function when you want continue countdown timer when you call stop function before.
///    4: - cancle function when you want to cancel countdow timer, it reset to default where you call init class.
///
///     Happy to using CountDown.
///
public class CountDownAtom: ObservableObject {
  
  private let countdow: Double
  
  private var count: Double
  
  private var isAutoCountdown: Bool
  
  private var withTimeInterval: TimeInterval
  
  private var timer: Timer?
  
  @Published
  public var phase: CountdownPhase = .pending
  
  public var value: Double {
    count
  }
  
  public init(
    countdow: Double,
    withTimeInterval: TimeInterval = 0.1,
    isAutoCountdown: Bool = false
  ) {
    self.countdow = countdow
    self.count = countdow
    self.withTimeInterval = withTimeInterval
    self.isAutoCountdown = isAutoCountdown
    makeInit()
  }
  
  private func makeInit() {
    self.timer = Timer.scheduledTimer(
      withTimeInterval: withTimeInterval,
      repeats: true
    ) { [weak self] _ in
      self?.runCountDown()
    }
  }
  
  private func runCountDown() {
    guard isAutoCountdown else { return }
    if count <= 0 {
      phase = .completion
      isAutoCountdown = false
    } else {
      count -= withTimeInterval
      phase = .process(count)
    }
  }
  
  deinit {
    timer?.invalidate()
    timer = nil
  }
  
  /// The function start countdown.
  public func start() {
    phase = .start(countdow)
    count = countdow
    isAutoCountdown = true
  }
  
  /// The function stop countdown.
  public func stop() {
    phase = .stop
    isAutoCountdown = false
  }
  
  /// The function play countdown when you call ``stop`` before.
  public func play() {
    isAutoCountdown = true
  }
  
  /// The function cancel countdown.
  public func cancel() {
    phase = .cancel
    count = countdow
    isAutoCountdown = false
  }
}

extension CountDownAtom {
  public enum CountdownPhase: Equatable {
    case pending
    case start(Double)
    case stop
    case cancel
    case process(Double)
    case completion
  }
}
