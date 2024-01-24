import SwiftUI
import Dependencies

extension EnvironmentValues {
  
  @EnvironmentValue
  var store: StoreContext = StoreContext(AtomStore(), enablesAssertion: false)
  
//  @EnvironmentValue
//  var recoilStoreContext: StoreContext = StoreContext(AtomStore(), enablesAssertion: false)
  
  @EnvironmentValue
  var riverpodContext: RiverpodContext = RiverpodContext(weakStore: .identity)
}

extension DependencyValues {
  
  @DependencyValue
  var storeContext: StoreContext = StoreContext(AtomStore(), enablesAssertion: false)
  
//  @DependencyValue
//  var recoilStoreContext: StoreContext = StoreContext(AtomStore(), enablesAssertion: false)
  
  @DependencyValue
  var riverpodContext: RiverpodContext  = RiverpodContext(weakStore: .identity)
}
