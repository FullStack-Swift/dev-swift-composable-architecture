import IdentifiedCollections
import Combine
import SwiftUI
import SwiftExt

// MARK: LocalObsrvable
/// LocalObservable like HookObservable, button it support multi hook state, with this, you can using hook in ForEach, Condition or ``do\catch`` controlflow. this is target of this object.
/// Do you have any  idea for this.

open class LocalObservable: ObservableObject {
  internal private(set) static weak var current: LocalObservable?
  
  /// A publisher that emits before the object has changed.
  public private(set) lazy var objectWillChange = ObservableObjectPublisher()
  
  private var records = SwiftExt.LinkedList<HookRecordProtocol>()
  private var scopedState: ScopedHookState?
  
  /// Creates a new `LocalObservable`.
  public init() {}
  
  deinit {
    disposeAll()
  }
  
  /// Disposes all state that already manaed with this instance.
  public func disposeAll() {
    for record in records.reversed() {
      record.dispose()
    }
    records = SwiftExt.LinkedList()
  }
  
//  public func use<H: Hook>(_ hook: H) -> H.State {
//    assertMainThread()
//    
//    guard let scopedState = scopedState else {
//      fatalErrorHooksRules()
//    }
//    
//    func makeCoordinator(state: H.State) -> HookCoordinator<H> {
//      HookCoordinator(
//        state: state,
//        environment: scopedState.environment,
//        updateView: updateView
//      )
//    }
//    
//    func updateView() {
//      Task { @MainActor [weak self] in
//        self?.objectWillChange.send()
//      }
//    }
//    
//    func appendNew() -> H.Value {
//      let state = hook.makeState()
//      let coordinator = makeCoordinator(state: state)
//      let record = HookRecord(hook: hook, coordinator: coordinator)
//      
//      scopedState.currentRecord = records.append(record)
//      
//      if hook.shouldDeferredUpdate {
//        scopedState.deferredUpdateRecords.append(record)
//      }
//      else {
//        hook.updateState(coordinator: coordinator)
//      }
//      
//      return hook.value(coordinator: coordinator)
//    }
//    
//    defer {
//      scopedState.currentRecord = scopedState.currentRecord?.next
//    }
//    
//    guard let record = scopedState.currentRecord else {
//      return appendNew()
//    }
//    
//    if let state = record.state(of: H.self) {
//      let coordinator = makeCoordinator(state: state)
//      let newRecord = HookRecord(hook: hook, coordinator: coordinator)
//      let oldRecord = record.swap(element: newRecord)
//      
//      if oldRecord.shouldUpdate(newHook: hook) {
//        if hook.shouldDeferredUpdate {
//          scopedState.deferredUpdateRecords.append(newRecord)
//        } else {
//          hook.updateState(coordinator: coordinator)
//        }
//      }
//      return hook.value(coordinator: coordinator)
//    } else {
//      scopedState.assertRecordingFailure(hook: hook, record: record.element)
//      // Fallback process for wrong usage.
//      sweepRemainingRecords()
//      return appendNew()
//    }
//
//  }
  
  @discardableResult
  public func scoped<Result>(
    environment: EnvironmentValues,
    _ body: () throws -> Result
  ) rethrows -> Result {
    let value = try body()
    return value
  }
  
  
  func updateView() {
    Task { @MainActor [weak self] in
      self?.objectWillChange.send()
    }
  }
}

private final class ScopedHookState {
  let environment: EnvironmentValues
  var currentRecord: SwiftExt.LinkedList<HookRecordProtocol>.Node?
  var deferredUpdateRecords = SwiftExt.LinkedList<HookRecordProtocol>()
  
  init(
    environment: EnvironmentValues,
    currentRecord: SwiftExt.LinkedList<HookRecordProtocol>.Node?
  ) {
    self.environment = environment
    self.currentRecord = currentRecord
  }
  
  func deferredUpdate() {
    for record in deferredUpdateRecords {
      record.updateState()
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
