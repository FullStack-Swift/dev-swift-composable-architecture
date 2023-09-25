import SwiftUI

// MARK: Reducer
struct AuthReducer: Reducer {

  // MARK: State
  struct State: BaseState {

  }

  // MARK: Action
  enum Action: Equatable {
    case viewOnAppear
    case viewOnDisappear
    case none
    case login
    case changeRootScreen(RootReducer.RootScreen)
  }

  // MARK: Dependency
  @Dependency(\.uuid) var uuid

  // MARK: Start Body
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        case .viewOnAppear:
          break
        case .viewOnDisappear:
          break
        case .login:
          return .send(.changeRootScreen(.main))
        default:
          break
      }
      return .none
    }
    ._printChanges()
  }
  // MARK: End Body
}

// MARK: Middleware
struct AuthMiddleware: Middleware {

  // MARK: State
  typealias State = AuthReducer.State

  // MARK: Action
  typealias Action = AuthReducer.Action

  // MARK: Start Body
  var body: some MiddlewareOf<Self> {
    IOMiddleware { state, action, source in
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

// MARK: View
struct AuthView: View {

  private let store: StoreOf<AuthReducer>

  @ObservedObject
  private var viewStore: ViewStoreOf<AuthReducer>

  init(store: StoreOf<AuthReducer>? = nil) {
    let unwrapStore = store ?? Store(
      initialState: AuthReducer.State()
    ) {
      AuthReducer()
    }
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore)
  }

  var body: some View {
    ZStack {
      Button("Login") {
        viewStore.send(.login)
      }
    }
    .onAppear {
      viewStore.send(.viewOnAppear)
    }
    .onDisappear {
      viewStore.send(.viewOnDisappear)
    }
  }
}

#Preview {
  AuthView()
}
