import Foundation

public protocol ProviderProtocol: ObservableObject {
  
  associatedtype Value
  
  var value: Value { get set }
}

open class Provider<T>: ProviderProtocol {
  /// Returns any type
  /// A service class / computed property (filtered list)
  
  public var value: T
  
  public init(_ initialState: T) {
    self.value = initialState
  }
  
  public convenience init(_ ref: Ref,_ initialState: () -> T) {
    self.init(initialState())
  }
}
