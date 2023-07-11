import Foundation

public protocol ProviderProtocol: ObservableObject, Identifiable, Hashable {
  
  associatedtype Value
  
  var value: Value { get set }
  
  var id: UUID { get }
}

extension ProviderProtocol {
//  public var id: UUID {
//    UUID()
//  }
  
  public func eraseAnyProvider() -> AnyProvider {
    AnyProvider(wrapped: self)
  }
  
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.eraseAnyProvider() == rhs.eraseAnyProvider()
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
  }
  
}

open class Provider<T>: ProviderProtocol {
  /// Returns any type
  /// A service class / computed property (filtered list)
  
  public var value: T
  
  public init(_ initialState: T) {
    self.value = initialState
  }

  public let id = UUID()
  
}

public struct AnyProvider: Identifiable, Hashable {
  //implement the same equality as in your AnyProvider
  public static func == (lhs: AnyProvider, rhs: AnyProvider) -> Bool {
    rhs.wrapped.id == lhs.wrapped.id
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrapped)
  }
  
  public var wrapped: any ProviderProtocol

  public var id: UUID {wrapped.id}
}
