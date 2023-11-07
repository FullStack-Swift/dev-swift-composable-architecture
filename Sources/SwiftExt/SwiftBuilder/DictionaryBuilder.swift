import Foundation

@resultBuilder
public enum DictionaryBuilder<Key: Hashable, Value> {
  
  public typealias Component = Dictionary<Key, Value>
  
  public static func buildBlock() -> Component {
    [:]
  }
  
  public static func buildBlock(_ component: Component) -> Component {
    component
  }
  
  public static func buildBlock(_ components: Component...) -> Component {
    components.reduce(into: [:]) { result, next in
      result.merge(next) { $1 }
    }
  }
  
  public static func buildOptional(_ component: Component?) -> Component {
    component ?? [:]
  }
  
  public static func buildEither(first component: Component) -> Component {
    component
  }
  
  public static func buildEither(second component: Component) -> Component {
    component
  }
  
  public static func buildLimitedAvailability(_ component: Component) -> Component {
    component
  }
}

public extension Dictionary {
  
  /// How to use this function:
  ///
  ///     let dict = Dictionary  {
  ///
  ///     }
  ///
  /// Return Dictionary from builder.
  init(@DictionaryBuilder<Key, Value> builder: () -> Dictionary) {
    self = builder()
  }
}

public func dictionaryBuilder<Key: Hashable, Value>(
  @DictionaryBuilder<Key, Value> builder: () -> Dictionary<Key, Value>
) -> Dictionary<Key, Value> {
  builder()
}
