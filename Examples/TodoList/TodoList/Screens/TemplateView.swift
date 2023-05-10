import SwiftUI

struct TemplateReducer: ReducerProtocol {

  // MARK: State
  struct State: Equatable {

  }

  // MARK: Action
  enum Action: Equatable {
    case viewOnAppear
    case viewOnDisappear
    case none
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
        default:
          break
      }
      return .none
    }
    ._printChanges()
  }
  // MARK: End Body
}

struct TemplateMiddleware: MiddlewareProtocol {

  // MARK: State
  typealias Action = TemplateReducer.Action

  // MARK: Action
  typealias State = TemplateReducer.State

  // MARK: Dependency
  @Dependency(\.uuid) var uuid

  // MARK: Body
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
  // MARK: End Body
}

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

struct TemplateView_Previews: PreviewProvider {
  static var previews: some View {
    TemplateView()
  }
}
