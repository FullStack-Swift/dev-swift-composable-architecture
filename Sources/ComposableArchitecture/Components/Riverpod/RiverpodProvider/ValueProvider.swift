import Dependencies
import Foundation

/// Returns any type
/// A filter condition / simple state object
open class ValueProvider<T>: ProviderProtocol {
  
  public var observable: ObservableListener = ObservableListener()
  
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
//    context.observable.sink(observable.send)
  }
}
