import Dependencies
import Foundation

/// Returns any type
/// A filter condition / simple state object
open class StateProvider<T>: ProviderProtocol {
  
  public var observable: ObservableListener = ObservableListener()
  
  public var value: T {
    willSet {
      observable.send()
    }
  }
  
  public let id = UUID()
  
  public init(_ initialState: T) {
    self.value = initialState
  }
  
  public convenience init(_ initialState: () -> T) {
    self.init(initialState())
  }
  
  public convenience init(_ initialState: (RiverpodContext) -> T) {
    @Dependency(\.riverpodContext)
    var riverpodContext
    self.init(initialState(riverpodContext))
  }
}
