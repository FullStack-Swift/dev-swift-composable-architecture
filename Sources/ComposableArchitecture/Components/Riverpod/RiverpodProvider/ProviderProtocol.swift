import Foundation

public protocol ProviderProtocol: Identifiable, Hashable {
  
  associatedtype Value
  
  var value: Value { get set }
  
  var id: UUID { get }
  
  var observable: ObservableListener { get set }
}

extension ProviderProtocol {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
  }
  
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.eraseAnyProvider() == rhs.eraseAnyProvider()
  }
  
  public func eraseAnyProvider() -> AnyProvider {
    AnyProvider(wrapped: self)
  }
}

/// Returns any type
/// A service class / computed property (filtered list)
open class Provider<T>: ProviderProtocol {
  
  public var observable: ObservableListener = ObservableListener()
  
  public var value: T
  
  public let id = UUID()
  
  public init(_ initialState: T) {
    self.value = initialState
  }
  
  public convenience init(_ initialState: () -> T) {
    self.init(initialState())
  }
}

public struct AnyProvider: Identifiable, Hashable {

  public var wrapped: any ProviderProtocol
  
  public var id: UUID {wrapped.id}
  
  public static func == (lhs: AnyProvider, rhs: AnyProvider) -> Bool {
    rhs.wrapped.id == lhs.wrapped.id
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrapped)
  }
}
