import Dependencies

extension DependencyValues {
  @DependencyValue
  public var urlString: String = "http://0.0.0.0:8080"
  
  @DependencyValue
  public var todoService: TodoService = TodoService()
}

extension DependencyValues {
  @DependencyValue
  var rootStore: StoreOf<RootReducer> = Store(
    initialState: RootReducer.State()
  ) {
    RootReducer()
  }
    .withMiddleware(RootMiddleware())
  
  var authStore: StoreOf<AuthReducer> {
    rootStore.scope(state: \.authState, action: RootReducer.Action.authAction)
      .withMiddleware(AuthMiddleware())
  }
  
  var mainStore: StoreOf<MainReducer> {
    rootStore.scope(state: \.mainState, action: RootReducer.Action.mainAction)
      .withMiddleware(MainMiddleware())
  }
  
  var counterStore: StoreOf<CounterReducer> {
    mainStore.scope(state: \.counterState, action: MainReducer.Action.counterAction)
      .withMiddleware(CounterMiddleware())
  }
}
