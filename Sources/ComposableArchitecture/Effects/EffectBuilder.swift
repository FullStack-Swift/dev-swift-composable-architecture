import Foundation

@resultBuilder
public struct EffectBuilder {
  public static func buildBlock<Action>(_ effects: Effect<Action>...) -> [Effect<Action>] {
    effects
  }
}

public extension Effect {
  static func concatenate(@EffectBuilder builder: () -> [Effect<Action>]) -> Effect<Action> {
    .concatenate(builder())
  }

  static func merge(@EffectBuilder builder: () -> [Effect<Action>]) -> Effect<Action> {
    .merge(builder())
  }
}
