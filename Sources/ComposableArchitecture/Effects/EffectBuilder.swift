import Foundation

@resultBuilder
public struct EffectBuilder {
  public static func buildBlock<Action>(_ effects: EffectTask<Action>...) -> [EffectTask<Action>] {
    effects
  }
}

public extension EffectTask {
  static func concatenate(@EffectBuilder builder: () -> [EffectTask<Action>]) -> EffectTask<Action> {
    .concatenate(builder())
  }

  static func merge(@EffectBuilder builder: () -> [EffectTask<Action>]) -> EffectTask<Action> {
    .merge(builder())
  }
}
