// MARK: Extension useEffect and useLayoutEffect

public func useEffectChanged(
  _ updateStrategy: HookUpdateStrategy? = nil,
  effect: (() -> Void)? = nil
) {
  useEffect(updateStrategy) {
    effect?()
    return nil
  }
}

public func useLayouEffectChanged(
  _ updateStrategy: HookUpdateStrategy? = nil,
  effect: (() -> Void)? = nil
) {
  useLayoutEffect(updateStrategy) {
    effect?()
    return nil
  }
}

public func useEffect(
  _ updateStrategy: HookUpdateStrategy? = nil,
  where condition: Bool = true,
  effect: (() -> Void)?
) {
  useEffect(updateStrategy) {
    if condition {
      effect?()
    }
    return nil
  }
}

public func useLayoutEffect(
  _ updateStrategy: HookUpdateStrategy? = nil,
  where condition: Bool = true,
  effect: (() -> Void)? = nil
) {
  useLayoutEffect(updateStrategy) {
    if condition {
      effect?()
    }
    return nil
  }
}
