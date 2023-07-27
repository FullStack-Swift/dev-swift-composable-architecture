import Combine
import SwiftUI

/// A testing tool that simulates the behaviors on a view of a given hook
/// and manages the resulting values.
/// It instead for HookScope.
public final class RecoilTester<Parameter, Value> {
  
  private var tester: HookTester<Parameter, Value>
  
  private var cancellable: AnyCancellable?
  
  /// The latest result value that the given Hook was executed.
  public var value: Value {
    tester.value
  }
  
  /// A history of the resulting values of the given Hook being executed.
  public var valueHistory: [Value] {
    tester.valueHistory
  }
  
  /// Event update UI
  public var observer: ObservableListener {
    tester.observer
  }
  
  /// Creates a new tester that simulates the behavior on a view of a given hook
  /// and manages the resulting values.
  /// - Parameters:
  ///   - initialParameter: An initial value of the parameter passed when calling the hook.
  ///   - hook: A closure for calling the hook under test.
  ///   - environment: A closure for mutating an `EnvironmentValues` that to be used for testing environment.
  public init(
    _ initialParameter: Parameter,
    _ hook: @escaping (Parameter) -> Value,
    environment: (inout EnvironmentValues) -> Void = { _ in }
  ) {
    self.tester = HookTester(initialParameter, hook, environment: environment)
//    cancellable = observer.publisher.sink(receiveValue: update)
  }
  
  /// Creates a new tester that simulates the behavior on a view of a given hook
  /// and manages the resulting values.
  /// - Parameters:
  ///   - hook: A closure for running the hook under test.
  ///   - environment: A closure for mutating an `EnvironmentValues` that to be used for testing environment.
  public init(
    _ hook: @escaping (Parameter) -> Value,
    environment: (inout EnvironmentValues) -> Void = { _ in }
  ) where Parameter == Void {
    self.tester = HookTester(hook, environment: environment)
//    cancellable = observer.publisher.sink(receiveValue: update)
  }
  
  public init<Context: AtomWatchableContext>(
    context: Context,
    _ hook: @escaping (Parameter) -> Value
  ) where Parameter == Void {
    self.tester = HookTester(hook)
//    cancellable = observer.publisher.sink(receiveValue: update)
  }
  
  /// Simulate a view update and re-call the hook under test with a given parameter.
  /// - Parameter parameter: A parameter value passed when calling the hook.
  public func update(with parameter: Parameter) {
    tester.update(with: parameter)
  }
  
  /// Simulate a view update and re-call the hook under test with the latest parameter that already applied.
  public func update() {
    tester.update()
  }
  
  /// Simulate view unmounting and disposes the hook under test.
  public func dispose() {
    tester.dispose()
  }
}
