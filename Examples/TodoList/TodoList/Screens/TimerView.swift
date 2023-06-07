import SwiftUI

// MARK: Reducer
struct TimerReducer: ReducerProtocol {

  // MARK: State
  struct State: BaseIDState {
    struct ID: Hashable {
      var uuid = UUID()
    }

    let id = ID()
    var count: Int = 0
  }

  // MARK: Action
  enum Action: Equatable {
    case viewOnAppear
    case viewOnDisappear
    case none
    case start
    case tick
  }

  // MARK: Dependency
  @Dependency(\.uuid) var uuid
  @Dependency(\.mainQueue) var mainQueue

  // MARK: Start Body
  var body: some ReducerProtocolOf<Self> {
    Reduce { state, action in
      switch action {
        case .viewOnAppear:
          break
        case .viewOnDisappear:
          break
        case .start:
          return EffectTask.timer(id: state.id, every: .seconds(1), on: mainQueue)
            .map { _ in .tick }
        case .tick:
          state.count += 1
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
struct TimerMiddleware: MiddlewareProtocol {

  // MARK: State
  typealias State = TimerReducer.State

  // MARK: Action
  typealias Action = TimerReducer.Action

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
struct TimerView: View {

  private let store: StoreOf<TimerReducer>

  @ObservedObject
  private var viewStore: ViewStoreOf<TimerReducer>

  init(store: StoreOf<TimerReducer>? = nil) {
    let unwrapStore = Store(
      initialState: TimerReducer.State(),
      reducer: TimerReducer()
    )
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore)
  }

  var body: some View {
    ZStack {
      Text("\(viewStore.count)")
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
struct TimerView_Previews: PreviewProvider {
  static var previews: some View {
    TimerView()
  }
}