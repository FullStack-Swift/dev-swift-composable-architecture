import SwiftUI
import Combine

open class ChangeNotifierProvider<P: ProviderProtocol>: ProviderProtocol
where P.ObjectWillChangePublisher == ObservableObjectPublisher {
  /// Returns a subclass of ChangeNotifier
  /// A complex state object that requires mutability
  
  @Republished
  public var state: P
  
  public var value: P.Value {
    get {
      state.value
    } set {
      state.value = newValue
    }
  }
  
  public init(_ initialState: P) {
    self._state = Republished(wrappedValue: initialState)
  }
  
  public convenience init(_ initialState: () -> P) {
    self.init(initialState())
  }
}
