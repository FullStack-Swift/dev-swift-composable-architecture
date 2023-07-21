import SwiftUI

/// Returns a subclass of StateNotifier
/// A complex state object that is immutable except through an interface
open class StateNotifierProvider<P: ProviderProtocol>: ProviderProtocol {
  
  public var observable: ObservableListener = ObservableListener()
  
  public var state: P
  
  public var value: P.Value {
    get {
      state.value
    } set {
      observable.send()
      state.value = newValue
    }
  }
  
  public let id = UUID()
  
  public init(_ initialState: P) {
    self.state = initialState
    state.observable.sink(observable.send)
  }
  
  public convenience init(_ initialState: () -> P) {
    self.init(initialState())
  }
  
  public convenience init(
    _ initialState: @escaping (RiverpodContext) -> P
  ) {
    @Dependency(\.riverpodContext) var riverpodContext
    self.init(initialState(riverpodContext))
  }
}
