import SwiftUI

// MARK: Reducer
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
  @Dependency(\.storage) var storage

  // MARK: Start Body
  var body: some ReducerProtocolOf<Self> {
    Reduce { state, action in
      switch action {
        case .viewOnAppear:
          state.count = storage.count
        case .increment:
          state.count += 1
          storage.count = state.count
        case .decrement:
          state.count -= 1
          storage.count = state.count
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
struct CounterMiddleware: MiddlewareProtocol {

  // MARK: State
  typealias State = CounterReducer.State

  // MARK: Action
  typealias Action = CounterReducer.Action

  // MARK: Dependency
  @Dependency(\.uuid) var uuid

  // MARK: Start Body
  var body: some MiddlewareProtocolOf<Self> {
    ioMiddleware
//    asyncIOMiddleware
//    actionHandlerMiddleware
//    asyncActionHandlerMiddleware
  }

  var ioMiddleware: some MiddlewareProtocolOf<Self> {
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
  }

  var asyncIOMiddleware: some MiddlewareProtocolOf<Self> {
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
  }

  var actionHandlerMiddleware: some MiddlewareProtocolOf<Self> {
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
  }

  var asyncActionHandlerMiddleware: some MiddlewareProtocolOf<Self> {
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

// MARK: View
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
      ScrollView {
        VStack {
          // MARK: store dispatch
          Group {
            Text("Store: dispatch()")
            HStack {
              Button {
                store.dispatch(.increment)
              } label: {
                Text("+")
              }
              Text(viewStore.count.toString())
              Button {
                store.dispatch(.decrement)
              } label: {
                Text("-")
              }
            }
          }
          // MARK: viewStore dispatch
          Group {
            Text("ViewStore: dispatch()")
            HStack {
              Button {
                viewStore.dispatch(.increment)
              } label: {
                Text("+")
              }
              Text(viewStore.count.toString())
              Button {
                viewStore.dispatch(.decrement)
              } label: {
                Text("-")
              }
            }

          }
          // MARK: ViewStore: send()
          Group {
            Text("ViewStore: send()")
            HStack {
              Button {
                viewStore.send(.increment)
              } label: {
                Text("+")
              }
              Text(viewStore.count.toString())
              Button {
                viewStore.send(.decrement)
              } label: {
                Text("-")
              }
            }
          }
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

// MARK: Previews
struct CounterView_Previews: PreviewProvider {
  static var previews: some View {
    CounterView(
      store: Store(initialState: .init(), reducer: CounterReducer())
        .withMiddleware(CounterMiddleware())
    )
  }
}
