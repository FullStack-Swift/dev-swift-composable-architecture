import ComposableArchitecture
import SwiftUI

struct AuthReducer: ReducerProtocol {

  // MARK: State
  struct State: Equatable {

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

  // MARK: Reducer
  var body: some ReducerProtocolOf<Self> {
    Reduce { state, action in
      switch action {
        case .viewOnAppear:
          break
        case .viewOnDisappear:
          break
        case .login:
          return EffectTask(value: .changeRootScreen(.main))
        default:
          break
      }
      return .none
    }
    ._printChanges()
  }
}

struct AuthMiddleware: MiddlewareProtocol {

  typealias Action = AuthReducer.Action

  typealias State = AuthReducer.State

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

struct AuthView: View {

  private let store: StoreOf<AuthReducer>

  @ObservedObject
  private var viewStore: ViewStoreOf<AuthReducer>

  init(store: StoreOf<AuthReducer>? = nil) {
    let unwrapStore = store ?? Store(
      initialState: AuthReducer.State(),
      reducer: AuthReducer()
    )
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

struct AuthView_Previews: PreviewProvider {
  static var previews: some View {
    AuthView()
  }
}
