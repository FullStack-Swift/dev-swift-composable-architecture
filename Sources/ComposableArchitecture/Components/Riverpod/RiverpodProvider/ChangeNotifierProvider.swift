import SwiftUI
import Combine

/// Returns a subclass of ChangeNotifier
/// A complex state object that requires mutability
open class ChangeNotifierProvider<P: ProviderProtocol>: ProviderProtocol {
  
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
  }
  
  public convenience init(_ initialState: () -> P) {
    self.init(initialState())
  }
}
