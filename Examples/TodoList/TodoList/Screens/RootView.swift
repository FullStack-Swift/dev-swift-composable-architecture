import SwiftUI

struct RootReducer: Reducer {

  // MARK: State
  struct State: BaseState {
    var authState = AuthReducer.State()
    var mainState = MainReducer.State()
    var rootScreen: RootScreen = .main
  }

  // MARK: Action
  enum Action { 
    case authAction(AuthReducer.Action)
    case mainAction(MainReducer.Action)
    case viewOnAppear
    case viewOnDisappear
    case none
    case changeRootScreen(RootScreen)
  }
  // MARK: Dependency
  @Dependency(\.uuid) var uuid

  // MARK: Start Body
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        case .authAction(.changeRootScreen(let screen)):
          return .send(.changeRootScreen(screen))
        case .mainAction(.changeRootScreen(let screen)):
          return .send(.changeRootScreen(screen))
        case .viewOnAppear:
          break
        case .viewOnDisappear:
          break
        case .changeRootScreen(let screen):
          state.rootScreen = screen
          switch screen {
            case .main:
              break
            case .auth:
              state.mainState = .init()
          }
        default:
          break
      }
      return .none
    }
    ._printChanges()
    authReducer
    mainReducer
  }

  var authReducer: some ReducerOf<Self> {
    Scope(state: \.authState, action: /Action.authAction) {
      AuthReducer()
    }
  }

  var mainReducer: some ReducerOf<Self> {
    Scope(state: \.mainState, action: /Action.mainAction) {
      MainReducer()
    }
  }
  // MARK: End Body

  // MARK: Utilities
  enum RootScreen {
    case main
    case auth
  }
}

struct RootMiddleware: Middleware {

  // MARK: State
  typealias State = RootReducer.State

  // MARK: Action
  typealias Action = RootReducer.Action

  // MARK: Dependency
  @Dependency(\.uuid) var uuid

  // MARK: Start Body
  var body: some MiddlewareOf<Self> {
    ioMiddleware
    asyncIOMiddleware
    actionHandlerMiddleware
    asyncActionHandlerMiddleware
  }

  var ioMiddleware: some MiddlewareOf<Self> {
    // MARK: IOMiddleware
    IOMiddleware { state, action, source in
      IO<Action> { handler in
        switch action {
          case .viewOnAppear:
            break
          case .viewOnDisappear:
            break
          default:
            break
        }
      }
    }
  }

  var asyncIOMiddleware: some MiddlewareOf<Self> {
    // MARK: AsyncIOMiddleware
    AsyncIOMiddleware { state, action, source in
      AsyncIO { handler in
        switch action {
          case .viewOnAppear:
            break
          case .viewOnDisappear:
            break
          default:
            break
        }
      }
    }
  }

  var actionHandlerMiddleware: some MiddlewareOf<Self> {
    // MARK: ActionHandlerMiddleware
    ActionHandlerMiddleware { state, action, source, handler in
      switch action {
        case .viewOnAppear:
          break
        case .viewOnDisappear:
          break
        default:
          break
      }
    }
  }

  var asyncActionHandlerMiddleware: some MiddlewareOf<Self> {
    // MARK: AsyncActionHandlerMiddleware
    AsyncActionHandlerMiddleware { state, action, source, handler in
      switch action {
        case .viewOnAppear:
          break
        case .viewOnDisappear:
          break
        default:
          break
      }
    }
  }
  // MARK: End Body
}

// MARK: View
struct RootView: View {

  private let store: StoreOf<RootReducer>

  @StateObject
//  @ObservedObject
  private var viewStore: ViewStoreOf<RootReducer>

  init(store: StoreOf<RootReducer>? = nil) {
    let unwrapStore = store ?? Store(
      initialState: RootReducer.State()
    ) {
    RootReducer()
    }
    self.store = unwrapStore
      .withMiddleware(RootMiddleware())
    self._viewStore = StateObject(wrappedValue: ViewStore(unwrapStore))
//    self.viewStore = ViewStore(unwrapStore)
  }

  var body: some View {
    ZStack {
      switch viewStore.rootScreen {
        case .main:
          MainView(
            store: store
              .scope(
                state: \.mainState,
                action: RootReducer.Action.mainAction
              )
          )
        case .auth:
          AuthView(
            store: store
              .scope(
                state: \.authState,
                action: RootReducer.Action.authAction
              )
          )
      }
    }
    .onAppear {
      viewStore.send(.viewOnAppear)
    }
    .onDisappear {
      viewStore.send(.viewOnDisappear)
    }
#if os(macOS)
    .frame(minWidth: 700, idealWidth: 700, maxWidth: .infinity, minHeight: 500, idealHeight: 500, maxHeight: .infinity, alignment: .center)
#endif
  }
}

// MARK: Previews
struct RootView_Previews: PreviewProvider {
  static var previews: some View {
    RootView(
      store: Store(initialState: .init()) {
        RootReducer()
      }
        .withMiddleware(RootMiddleware())
    )
  }
}
