import SwiftUI
import Dependencies

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
    get {
      self[StoreContextDependencyKey.self]
    }
    set {
      self[StoreContextDependencyKey.self] = newValue
    }
  }
}

// MARK: StoreContextDependencyKey
private struct StoreContextDependencyKey: DependencyKey {
   static var liveValue = StoreContext(AtomStore(), enablesAssertion: false)
}

extension DependencyValues {
  var recoilStoreContext: StoreContext {
    get {
      self[RecoilStoreContextDependencyKey.self]
    }
    set {
      self[RecoilStoreContextDependencyKey.self] = newValue
    }
  }
}

// MARK: StoreContextDependencyKey
private struct RecoilStoreContextDependencyKey: DependencyKey {
  static var liveValue = StoreContext(AtomStore(), enablesAssertion: false)
}
