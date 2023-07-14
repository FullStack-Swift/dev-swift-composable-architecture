import Foundation

public protocol ProviderProtocol: ObservableObject, Identifiable, Hashable {
  
  associatedtype Value
  
  var value: Value { get set }
  
  var id: UUID { get }
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

open class Provider<T>: ProviderProtocol {
  /// Returns any type
  /// A service class / computed property (filtered list)
  
  public var value: T
  
  public init(_ initialState: T) {
    self.value = initialState
  }
  
  public convenience init(_ initialState: () -> T) {
    self.init(initialState())
  }

  public let id = UUID()
  
}

public struct AnyProvider: Identifiable, Hashable {

  public static func == (lhs: AnyProvider, rhs: AnyProvider) -> Bool {
    rhs.wrapped.id == lhs.wrapped.id
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrapped)
  }
  
  public var wrapped: any ProviderProtocol

  public var id: UUID {wrapped.id}
}
