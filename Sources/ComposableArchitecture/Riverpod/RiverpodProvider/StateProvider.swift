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

open class ValueProvider<T>: ProviderProtocol {
  /// Returns any type
  /// A filter condition / simple state object
  
  open var result: T {
    fatalError()
  }
  
  public var value: T {
    get {
      result
    }
    set {

    }
  }
  
  private var _value: T?
  
  @Dependency(\.riverpodContext)
  public var context
  
  public let id = UUID()
  
  public init() {
    _value = nil
  }
  
  public init(_ initialState: T) {
    self._value = initialState
  }
  
  public convenience init(_ initialState: () -> T) {
    self.init(initialState())
  }
  
  public convenience init(_ initialState: (RiverpodContext) -> T) {
    @Dependency(\.riverpodContext)
    var context
    self.init(initialState(context))
  }
}
