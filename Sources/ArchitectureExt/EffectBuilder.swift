#if canImport(ComposableArchitecture)
import ComposableArchitecture
import SwiftExt

extension Effect {
  
  /// Merges a variadic list of effects together into a single effect, which runs the effects at the
  /// same time.
  ///
  /// - Parameter builder: A  list of effects.
  /// - Returns: A new effect
  @inlinable
  public static func merge(@ArrayBuilder<Self> builder: () -> [Self]) -> Self {
    Self.merge(builder())
  }
  
  /// Merges a variadic list of effects together into a single effect, which runs the effects at the
  /// same time.
  ///
  /// - Parameter builder: A  list of effects.
  /// - Returns: A new effect
  @inlinable
  public static func mergeAction(@ArrayBuilder<Effect<Action>> builder: () -> [Effect<Action>]) -> Effect<Action> {
    Self.merge(builder())
  }
  
  /// Concatenates a variadic list of effects together into a single effect, which runs the effects
  /// one after the other.
  ///
  /// - Parameter builder: A  list of effects.
  /// - Returns: A new effect
  @inlinable
  public static func concatenate(@ArrayBuilder<Self> builder: () -> [Self]) -> Self {
    Self.concatenate(builder())
  }
  
  /// Concatenates a variadic list of effects together into a single effect, which runs the effects
  /// one after the other.
  ///
  /// - Parameter builder: A  list of effects.
  /// - Returns: A new effect
  @inlinable
  public static func concatenateAction(@ArrayBuilder<Effect<Action>> builder: () -> [Effect<Action>]) -> Effect<Action> {
    Self.concatenate(builder())
  }
}
#endif
