import SwiftUI

struct RootReducer: ReducerProtocol {

  // MARK: State
  struct State: Equatable {
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

  // MARK: Reducer
  var body: some ReducerProtocolOf<Self> {
    Reduce { state, action in
      switch action {
        case .authAction(.changeRootScreen(let screen)):
          return EffectTask(value: .changeRootScreen(screen))
        case .mainAction(.changeRootScreen(let screen)):
          return EffectTask(value: .changeRootScreen(screen))
        case .viewOnAppear:
          break
        case .viewOnDisappear:
          break
        case .changeRootScreen(let screen):
          state.rootScreen = screen
        default:
          break
      }
      return .none
    }
    ._printChanges()
    Scope(state: \.authState, action: /Action.authAction) {
      AuthReducer()
    }
    Scope(state: \.mainState, action: /Action.mainAction) {
      MainReducer()
    }
  }
  // MARK: Utilities
  enum RootScreen {
    case main
    case auth
  }
}

struct RootMiddleware: MiddlewareProtocol {

  typealias State = RootReducer.State

  typealias Action = RootReducer.Action

  var body: some MiddlewareProtocolOf<Self> {
    IOMiddleware { action, source, state in
      IO<Action> { output in
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
  // MARK: End
}

struct RootView: View {

  private let store: StoreOf<RootReducer>

  @ObservedObject
  private var viewStore: ViewStoreOf<RootReducer>

  init(store: StoreOf<RootReducer>? = nil) {
    let unwrapStore = store ?? Store(
      initialState: RootReducer.State(),
      reducer: RootReducer()
    )
    self.store = unwrapStore
      .withMiddleware(RootMiddleware())
    self.viewStore = ViewStore(unwrapStore)
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
