import Dependencies

// MARK: Store
extension DependencyValues {
  fileprivate struct RootStoreKey: DependencyKey {
    static let liveValue = Store(
      initialState: RootReducer.State(),
      reducer: RootReducer()
    )
      .withMiddleware(RootMiddleware())
  }
}

extension DependencyValues {
  var rootStore: StoreOf<RootReducer> {
    self[RootStoreKey.self]
  }
  
  var authStore: StoreOf<AuthReducer> {
    rootStore.scope(state: \.authState, action: RootReducer.Action.authAction)
  }
  
  var mainStore: StoreOf<MainReducer> {
    rootStore.scope(state: \.mainState, action: RootReducer.Action.mainAction)
  }
  
  var counterStore: StoreOf<CounterReducer> {
    mainStore.scope(state: \.counterState, action: MainReducer.Action.counterAction)
  }
}
