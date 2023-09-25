import SwiftUI

// MARK: Reducer
struct CounterReducer: Reducer {

  // MARK: State
  struct State: BaseIDState {
    var count: Int = 0
    var id: UUID = UUID()
    @BindingState var text: String = "viewStoreText"
  }

  // MARK: Action
  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case onFirstAppear
    case viewOnAppear
    case viewOnDisappear
    case onLastDisappear
    case none
    case increment
    case decrement
  }

  // MARK: Dependency
  @Dependency(\.uuid) var uuid
  @Dependency(\.storage) var storage
//  @Dependency(\.sharedState) var sharedState
  @Dependency(\.sharedStateStore) var sharedStateStore

//  @SharedState(\.count) var count

  // MARK: Start Body
  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
        case .onFirstAppear:
          break
        case .viewOnAppear:
//          state.count = storage.count
          break
        case .viewOnDisappear:
          break
        case .onLastDisappear:
          state.count = 10000
          break
        case .increment:
//          state.count += 1
//          storage.count = state.count
//          sharedState.count = state.count
//          sharedState.count += 1
//          count += 1
          break
        case .decrement:
//          state.count -= 1
//          storage.count = state.count
//          sharedState.count = state.count
//          sharedState.count -= 1
//          count -= 1
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
struct CounterMiddleware: Middleware {

  // MARK: State
  typealias State = CounterReducer.State

  // MARK: Action
  typealias Action = CounterReducer.Action

  // MARK: Dependency
  @Dependency(\.uuid) var uuid

  // MARK: Start Body
  var body: some MiddlewareOf<Self> {
    ioMiddleware
//    asyncIOMiddleware
//    actionHandlerMiddleware
//    asyncActionHandlerMiddleware
  }

  var ioMiddleware: some MiddlewareOf<Self> {
    // MARK: IOMiddleware
    IOMiddleware { state, action, source in
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

  var asyncIOMiddleware: some MiddlewareOf<Self> {
    // MARK: AsyncIOMiddleware
    AsyncIOMiddleware { state, action, source in
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

  var actionHandlerMiddleware: some MiddlewareOf<Self> {
    // MARK: ActionHandlerMiddleware
    ActionHandlerMiddleware { state, action, source, handler in
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

  var asyncActionHandlerMiddleware: some MiddlewareOf<Self> {
    // MARK: AsyncActionHandlerMiddleware
    AsyncActionHandlerMiddleware { state, action, source, handler in
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

  @StateObject
//  @ObservedObject
  private var viewStore: ViewStoreOf<CounterReducer>

//  @SharedState(\.count) var count
//  @Dependency(\.sharedState) var sharedState
//  @Dependency(\.sharedStateViewStore) var sharedStateViewStore
  @ViewModel(\.counterStore) var counterViewModel

  init(store: StoreOf<CounterReducer>? = nil) {
    let unwrapStore = Store(
      initialState: CounterReducer.State()
    ) {
      CounterReducer()
    }
    self.store = unwrapStore
      .withMiddleware(CounterMiddleware())
    self._viewStore = StateObject(wrappedValue: ViewStore(unwrapStore))
//    self.viewStore = ViewStore(unwrapStore)
  }

  var body: some View {
    ZStack {
      ScrollView {
        VStack {
          commitView
//          // MARK: store dispatch
//          Group {
//            Text("Store: dispatch()")
//            HStack {
//              Button {
////                store.dispatch(.increment)
////                counterNumber.count += 1
////                count += 1
//                counterViewModel.count += 1
//              } label: {
//                Text("+")
//              }
////              Text(viewStore.count.toString())
////              Text(count.toString())
////              Text(sharedState.count.toString())
//              Text(counterViewModel.count.toString())
//              Button {
//                store.dispatch(.decrement)
//              } label: {
//                Text("-")
//              }
//            }
//          }
//          // MARK: viewStore dispatch
//          Group {
//            Text("ViewStore: dispatch()")
//            HStack {
//              Button {
//                viewStore.dispatch(.increment)
//              } label: {
//                Text("+")
//              }
////              Text(viewStore.count.toString())
//              Text(count.toString())
//              Button {
//                viewStore.dispatch(.decrement)
//              } label: {
//                Text("-")
//              }
//            }
//
//          }
//          // MARK: ViewStore: send()
//          Group {
//            Text("ViewStore: send()")
//            HStack {
//              Button {
//                viewStore.send(.increment)
//              } label: {
//                Text("+")
//              }
////              Text(viewStore.count.toString())
//              Text(count.toString())
//              Button {
//                viewStore.send(.decrement)
//              } label: {
//                Text("-")
//              }
//            }
//          }


        }
      }
    }
    .onFirstAppear {
      log.info("onFirstAppear")
    }
    .onAppear {
//      viewStore.send(.viewOnAppear)
      log.info("onAppear")
    }
    .onDisappear {
//      viewStore.send(.viewOnDisappear)
      log.info("onDisappear")
    }
    .onLastDisappear {
      log.info("onLastDisappear")
    }
  }
}

extension CounterView {
  var commitView: some View {
    HookScope {
      // MARK: ViewStore: commit

      let useStateText = useState("useStateText")
//      let viewStoreText = viewStore.binding(\.$text)
//      let text = viewStoreText <> useStateText
//      let text = useStateText <> viewStoreText
//      let text = useStateText.binding(viewStoreText)
      //      let text = viewStore.binding(\.$text).binding(useState("123"))
//        let text = useBinding([viewStore.binding(\.$text), useState("123")]) ?? ""
//      let text = Binding.constant("a")
//      useMemo(.once) {
//        store.commit {
//          $0.text = text.wrappedValue
//        }
//      }

      Group {

        Text("ViewStore: send()")
        VStack {
          TextField("useStateText", text: useStateText)
//          TextField("viewStoreText", text: viewStoreText)
//          TextField("text", text: text)
          Text(useStateText.wrappedValue.isEmpty ? "Nothing to show" : useStateText.wrappedValue)
//          Text(viewStoreText.wrappedValue.isEmpty ? "Nothing to show" : viewStoreText.wrappedValue)
//          Text(text.wrappedValue.isEmpty ? "Nothing to show" : text.wrappedValue)
        }
        HStack {
          Button {
            store.commit {
              $0.count += 1
            }
          } label: {
            Text("+")
          }
          Text(viewStore.count.toString())
          Button {
            store.commit {
              $0.count -= 1
            }
          } label: {
            Text("-")
          }
        }
      }
      .onLastDisappear {
        store.count = 1000011
        store.commit {
          $0.count = 100001
        }
      }
    }
  }
}

#Preview {
  CounterView()
}
