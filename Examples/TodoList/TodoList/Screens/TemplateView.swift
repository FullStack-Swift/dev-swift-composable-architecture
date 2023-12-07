import SwiftUI

// MARK: Reducer
@Reducer
struct TemplateReducer {

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
  var body: some ReducerOf<Self> {
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
struct TemplateMiddleware: Middleware {

  // MARK: State
  typealias State = TemplateReducer.State

  // MARK: Action
  typealias Action = TemplateReducer.Action

  // MARK: Dependency
  @Dependency(\.uuid) var uuid

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
  // MARK: End Body
}

// MARK: View
struct TemplateView: View {

  private let store: StoreOf<TemplateReducer>

  @ObservedObject
  private var viewStore: ViewStoreOf<TemplateReducer>

  init(store: StoreOf<TemplateReducer>? = nil) {
    let unwrapStore = Store(
      initialState: TemplateReducer.State()
    ) {
      TemplateReducer()
    }
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

#Preview {
  TemplateView()
}
