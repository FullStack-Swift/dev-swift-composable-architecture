import SwiftUI
import Dependencies

open class StateProvider<T>: ProviderProtocol {
  /// Returns any type
  /// A filter condition / simple state object
  
  @Published public var value: T
  
  @Dependency(\.riverpodContext)
  public var riverpodContext
  
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
