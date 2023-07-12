import SwiftUI
import Combine

open class StateNotifierProvider<P: ProviderProtocol>: ProviderProtocol
where P.ObjectWillChangePublisher == ObservableObjectPublisher {
  /// Returns a subclass of StateNotifier
  /// A complex state object that is immutable except through an interface
  @Republished
  public var state: P
  
  public var value: P.Value {
    get {
      state.value
    } set {
      state.value = newValue
    }
  }
  
  public let id = UUID()
  
  public init(_ initialState: P) {
    self._state = Republished(wrappedValue: initialState)
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
