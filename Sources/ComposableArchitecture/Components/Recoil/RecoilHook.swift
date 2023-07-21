import Foundation

public protocol RecoilHook: Hook {
  associatedtype T
  var initialValue: T { get }
}

internal final class RecoilHookRef<Value> {
  private(set) var value: Value
  private(set) var isDisposed = false
  
  @RecoilGlobalViewContext
  var context
  
  init(initialState: Value) {
    value = initialState
  }
  
  func update(newValue: Value, context: RecoilGlobalViewContext) {
    self.value = newValue
    self._context = context
  }
  
  func dispose() {
    isDisposed = true
  }
}


extension RecoilHook where State == RecoilHookRef<T> {
  @MainActor
  func makeState() -> RecoilHookRef<T> {
    RecoilHookRef(initialState: initialValue)
  }
  
  @MainActor
  func makeSContext(coordinator: Coordinator) -> RecoilGlobalViewContext {
    fatalError()
  }
  
  @MainActor
  func getStoreContext(coordinator: Coordinator) -> RecoilGlobalContext {
    fatalError()
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {

  }
  
  @MainActor
  func dispose(state: RecoilHookRef<T>) {
    state.dispose()
  }
}
