import SwiftUI

// MARK: Reducer
struct TemplateReducer: ReducerProtocol {

  // MARK: State
  struct State: BaseState {

  }

  // MARK: Action
  enum Action: Equatable {
    case viewOnAppear
    case viewOnDisappear
    case none
  }

  // MARK: Dependency
  @Dependency(\.uuid) var uuid

  // MARK: Start Body
  var body: some ReducerProtocolOf<Self> {
    Reduce { state, action in
      switch action {
        case .viewOnAppear:
          break
        case .viewOnDisappear:
          break
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
struct TemplateMiddleware: MiddlewareProtocol {

  // MARK: State
  typealias State = TemplateReducer.State

  // MARK: Action
  typealias Action = TemplateReducer.Action

  // MARK: Dependency
  @Dependency(\.uuid) var uuid

  // MARK: Start Body
  var body: some MiddlewareProtocolOf<Self> {
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
  // MARK: End Body
}

// MARK: View
struct TemplateView: View {

  private let store: StoreOf<TemplateReducer>

  @ObservedObject
  private var viewStore: ViewStoreOf<TemplateReducer>

  init(store: StoreOf<TemplateReducer>? = nil) {
    let unwrapStore = Store(
      initialState: TemplateReducer.State(),
      reducer: TemplateReducer()
    )
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore)
  }

  var body: some View {
    ZStack {

    }
    .onAppear {
      viewStore.send(.viewOnAppear)
    }
    .onDisappear {
      viewStore.send(.viewOnDisappear)
    }
  }
}

// MARK: Previews
struct TemplateView_Previews: PreviewProvider {
  static var previews: some View {
    TemplateView()
  }
}
