import Combine
import SwiftUI

/// A class that manages list of states of hooks used inside `HookObservable.scoped(environment:_)`.
public final class HookObservable: ObservableObject {
  internal private(set) static weak var current: HookObservable?
  
  /// A publisher that emits before the object has changed.
  public private(set) lazy var objectWillChange = ObservableObjectPublisher()
  
  private var records = LinkedList<HookRecordProtocol>()
  private var scopedState: ScopedHookState?
  
  /// Creates a new `HookObservable`.
  public init() {}
  
  deinit {
    disposeAll()
  }
  
  /// Disposes all hooks that already managed with this instance.
  public func disposeAll() {
    for record in records.reversed() {
      record.element.dispose()
    }
    
    records = LinkedList()
  }
  
  /// Returns given hooks value with managing its state and update it if needed.
  /// - Parameter hook: A hook to be used.
  /// - Returns: A value that provided from the given hook.
  public func use<H: Hook>(_ hook: H) -> H.Value {
    assertMainThread()
    
    guard let scopedState = scopedState else {
      fatalErrorHooksRules()
    }
    
    func makeCoordinator(state: H.State) -> HookCoordinator<H> {
      HookCoordinator(
        state: state,
        environment: scopedState.environment,
        updateView: updateView
      )
    }
    
    func updateView() {
      Task { @MainActor in
        self.objectWillChange.send()
      }
    }
    
    func appendNew() -> H.Value {
      let state = hook.makeState()
      let coordinator = makeCoordinator(state: state)
      let record = HookRecord(hook: hook, coordinator: coordinator)
      
      scopedState.currentRecord = records.append(record)
      
      if hook.shouldDeferredUpdate {
        scopedState.deferredUpdateRecords.append(record)
      }
      else {
        hook.updateState(coordinator: coordinator)
      }
      
      return hook.value(coordinator: coordinator)
    }
    
    defer {
      scopedState.currentRecord = scopedState.currentRecord?.next
    }
    
    guard let record = scopedState.currentRecord else {
      return appendNew()
    }
    
    if let state = record.element.state(of: H.self) {
      let coordinator = makeCoordinator(state: state)
      let newRecord = HookRecord(hook: hook, coordinator: coordinator)
      let oldRecord = record.swap(element: newRecord)
      
      if oldRecord.shouldUpdate(newHook: hook) {
        if hook.shouldDeferredUpdate {
          scopedState.deferredUpdateRecords.append(newRecord)
        } else {
          hook.updateState(coordinator: coordinator)
        }
      }
      return hook.value(coordinator: coordinator)
    } else {
      scopedState.assertRecordingFailure(hook: hook, record: record.element)
      // Fallback process for wrong usage.
      sweepRemainingRecords()
      return appendNew()
    }
  }
  
  /// Executes the given `body` function that needs `HookObservable` instance with managing hooks state.
  /// - Parameters:
  ///   - environment: A environment values that can be used for hooks used inside the `body`.
  ///   - body: A function that needs `HookObservable` and is executed inside.
  /// - Throws: Rethrows an error if the given function throws.
  /// - Returns: A result value that the given `body` function returns.
  public func scoped<Result>(
    environment: EnvironmentValues,
    _ body: () throws -> Result
  ) rethrows -> Result {
    
    assertMainThread()
    
    let previous = Self.current
    
    Self.current = self
    
    let scopedState = ScopedHookState(
      environment: environment,
      currentRecord: records.first
    )
    
    self.scopedState = scopedState
    
    let value = try body()
    
    scopedState.deferredUpdate()
    scopedState.assertConsumedState()
    sweepRemainingRecords()
    
    self.scopedState = nil
    
    Self.current = previous
    
    return value
  }
}

private extension HookObservable {
  func sweepRemainingRecords() {
    guard let scopedState = scopedState, let currentRecord = scopedState.currentRecord else {
      return
    }
    
    let remaining = records.dropSuffix(from: currentRecord)
    
    for record in remaining.reversed() {
      record.element.dispose()
    }
    
    scopedState.currentRecord = records.last
  }
}

private final class ScopedHookState {
  let environment: EnvironmentValues
  var currentRecord: LinkedList<HookRecordProtocol>.Node?
  var deferredUpdateRecords = LinkedList<HookRecordProtocol>()
  
  init(
    environment: EnvironmentValues,
    currentRecord: LinkedList<HookRecordProtocol>.Node?
  ) {
    self.environment = environment
    self.currentRecord = currentRecord
  }
  
  func deferredUpdate() {
    for record in deferredUpdateRecords {
      record.element.updateState()
    }
  }
  
  func assertConsumedState() {
    guard !environment.hooksRulesAssertionDisabled else {
      return
    }
    
    assert(
      currentRecord == nil,
            """
            Some Hooks are no longer used from the previous evaluation.
            Hooks relies on the order in which they are called. Do not call Hooks inside loops, conditions, or nested functions.
            
            - SeeAlso: https://reactjs.org/docs/hooks-rules.html#only-call-hooks-at-the-top-level
            """
    )
  }
  
  func assertRecordingFailure<H: Hook>(hook: H, record: HookRecordProtocol) {
    guard !environment.hooksRulesAssertionDisabled else {
      return
    }
    debugAssertionFailure(
            """
            The type of Hooks did not match with the type evaluated in the previous evaluation.
            Previous hook: \(record.hookName)
            Current hook: \(type(of: hook))
            Hooks relies on the order in which they are called. Do not call Hooks inside loops, conditions, or nested functions.
            
            - SeeAlso: https://reactjs.org/docs/hooks-rules.html#only-call-hooks-at-the-top-level
            """
    )
  }
}

private struct HookRecord<H: Hook>: HookRecordProtocol {
  let hook: H
  let coordinator: HookCoordinator<H>
  
  var hookName: String {
    String(describing: type(of: hook))
  }
  
  func state<HookType: Hook>(of hookType: HookType.Type) -> HookType.State? {
    coordinator.state as? HookType.State
  }
  
  func shouldUpdate<New: Hook>(newHook: New) -> Bool {
    guard let newStrategy = newHook.updateStrategy else {
      return true
    }
    
    return hook.updateStrategy?.dependency != newStrategy.dependency
  }
  
  func updateState() {
    hook.updateState(coordinator: coordinator)
  }
  
  func dispose() {
    hook.dispose(state: coordinator.state)
  }
}

private protocol HookRecordProtocol {
  var hookName: String { get }
  
  func state<H: Hook>(of hookType: H.Type) -> H.State?
  
  func shouldUpdate<New: Hook>(newHook: New) -> Bool
  
  func updateState()
  
  func dispose()
}

/// HookObservable Ext
extension HookObservable {
  
}
