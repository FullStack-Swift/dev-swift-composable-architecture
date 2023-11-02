import Foundation

public protocol BackportExtensionsProvider {}

extension BackportExtensionsProvider {
  /// A proxy which hosts backport extensions for `self`.
  public var backport: Backport<Self> {
    Backport(self)
  }
  /// A proxy which hosts static backport extensions for the type of `self`.
  public static var backport: Backport<Self>.Type {
    Backport<Self>.self
  }
}

/// A proxy which hosts reactive extensions of `Base`.
public struct Backport<Base> {
  /// The `Base` instance the extensions would be invoked with.
  public let base: Base
  
  /// Construct a proxy
  ///
  /// - parameters:
  ///   - base: The object to be proxied.
  public init(_ content: Base) {
    self.base = content
  }
}
