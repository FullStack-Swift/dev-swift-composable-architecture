import SwiftUI

struct CounterReducer: ReducerProtocol {

  // MARK: State
  struct State: Equatable, Identifiable {
    var count: Int = 0
    var id: UUID = UUID()
  }

  // MARK: Action
  enum Action: Equatable {
    case viewOnAppear
    case viewOnDisappear
    case none
    case increment
    case decrement
  }

  // MARK: Dependency
  @Dependency(\.uuid) var uuid

  // MARK: Reducer
  var body: some ReducerProtocolOf<Self> {
    Reduce { state, action in
      switch action {
        case .increment:
          state.count += 1
          return .none
        case .decrement:
          state.count -= 1
          return .none
        default:
          return .none
      }
    }
    ._printChanges()
  }
  // MARK: End Body
}

struct CounterMiddleware: MiddlewareProtocol {

  // MARK: State
  typealias State = CounterReducer.State

  // MARK: Action
  typealias Action = CounterReducer.Action

  // MARK: Dependency
  @Dependency(\.uuid) var uuid

  // MARK: Body
  var body: some MiddlewareProtocolOf<Self> {
    // MARK: IOMiddleware
    IOMiddleware { action, source, state in
      IO<Action> { handler in
        switch action {
          case .decrement:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
              handler.dispatch(.decrement)
            }
          case .increment:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
              handler.dispatch(.increment)
            }
          default:
            break
        }
      }
    }

    // MARK: AsyncIOMiddleware
    AsyncIOMiddleware { action, source, state in
      AsyncIO { handler in
        switch action {
          case .decrement:
            try await Task.sleep(nanoseconds: 1_000_000_000)
            handler.dispatch(.decrement)
          case .increment:
            try await Task.sleep(nanoseconds: 1_000_000_000)
            handler.dispatch(.increment)
          default:
            break
        }
      }
    }

    // MARK: ActionHandlerMiddleware
    ActionHandlerMiddleware { action, source, state, handler in
      switch action {
        case .decrement:
          DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            handler.dispatch(.decrement)
          }
        case .increment:
          DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            handler.dispatch(.increment)
          }
        default:
          break
      }
    }

    // MARK: AsyncActionHandlerMiddleware
    AsyncActionHandlerMiddleware { action, source, state, handler in
      switch action {
        case .decrement:
          try await Task.sleep(nanoseconds: 1_000_000_000)
          handler.dispatch(.decrement)
        case .increment:
          try await Task.sleep(nanoseconds: 1_000_000_000)
          handler.dispatch(.increment)
        default:
          break
      }
    }
  }
  // MARK: End Body
}

struct CounterView: View {

  private let store: StoreOf<CounterReducer>

  @ObservedObject
  private var viewStore: ViewStoreOf<CounterReducer>

  init(store: StoreOf<CounterReducer>? = nil) {
    let unwrapStore = Store(
      initialState: CounterReducer.State(),
      reducer: CounterReducer()
    )
    self.store = unwrapStore
      .withMiddleware(CounterMiddleware())
    self.viewStore = ViewStore(unwrapStore)
  }

  var body: some View {
    ZStack {
      HStack {
        Button {
//          viewStore.send(.increment)
          store.dispatch(.increment)
        } label: {
          Text("+")
        }
        Text(viewStore.count.toString())
        Button {
//          viewStore.send(.decrement)
          store.dispatch(.decrement)
        } label: {
          Text("-")
        }
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

struct CounterView_Previews: PreviewProvider {
  static var previews: some View {
    CounterView()
  }
}
