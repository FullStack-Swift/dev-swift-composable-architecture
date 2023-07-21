import SwiftUI
import Dependencies

// MARK: Atom EnvironmentValues
internal extension EnvironmentValues {
  var store: StoreContext {
    get { self[StoreEnvironmentKey.self] }
    set { self[StoreEnvironmentKey.self] = newValue }
  }
}

private struct StoreEnvironmentKey: EnvironmentKey {
  static var defaultValue: StoreContext {
    @Dependency(\.storeContext) var storeContext
    return storeContext
  }
}

extension DependencyValues {
  var storeContext: StoreContext {
    get { self[StoreContextDependencyKey.self] }
    set { self[StoreContextDependencyKey.self] = newValue }
  }
}

private struct StoreContextDependencyKey: DependencyKey {
   static var liveValue = StoreContext(AtomStore(), enablesAssertion: false)
}

// MARK: Recoil EnvironmentValues
internal extension EnvironmentValues {
  var recoilStoreContext: StoreContext {
    get { self[RecoilStoreContextEnvironmentKey.self] }
    set { self[RecoilStoreContextEnvironmentKey.self] = newValue }
  }
}

private struct RecoilStoreContextEnvironmentKey: EnvironmentKey {
  static var defaultValue: StoreContext {
    @Dependency(\.recoilStoreContext) var recoilStoreContext
    return recoilStoreContext
  }
}

extension DependencyValues {
  var recoilStoreContext: StoreContext {
    get { self[RecoilStoreContextDependencyKey.self] }
    set { self[RecoilStoreContextDependencyKey.self] = newValue }
  }
}

private struct RecoilStoreContextDependencyKey: DependencyKey {
  static var liveValue = StoreContext(AtomStore(), enablesAssertion: false)
}

// MARK: Riverpod EnvironmentValues
internal extension EnvironmentValues {
  var riverpodContext: RiverpodContext {
    get { self[RivePodEnvironmentKey.self] }
    set { self[RivePodEnvironmentKey.self] = newValue }
  }
}

private struct RivePodEnvironmentKey: EnvironmentKey {
  static var defaultValue: RiverpodContext {
    @Dependency(\.riverpodContext) var riverpodContext
    return riverpodContext
  }
}

extension DependencyValues {
  var riverpodContext: RiverpodContext {
    get { self[RiverpodContextDependencyKey.self] }
    set { self[RiverpodContextDependencyKey.self] = newValue }
  }
}

private struct RiverpodContextDependencyKey: DependencyKey {
  static var liveValue = RiverpodContext(weakStore: .identity)
}
