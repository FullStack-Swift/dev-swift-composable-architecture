import ComposableArchitecture
import SwiftUI

// MARK: - Counter
struct Counter: ReducerProtocol {

  // MARK: State
  struct State: Equatable {
    var count = 0
  }

// MARK: Action
  enum Action: Equatable {
    case decrementButtonTapped
    case incrementButtonTapped
  }

  // MARK: Dependency
  @Dependency(\.uuid) var uuid

  // MARK: Body
  var body: some ReducerProtocolOf<Self> {
    NoneEffectReducer { state, action in
      switch action {
        case .decrementButtonTapped:
          print("CounterReducerProtocol: ", action)
          state.count -= 1
        case .incrementButtonTapped:
          print("CounterReducerProtocol: ", action)
          state.count += 1
      }
    }
//    Reduce { state, action in
//      switch action {
//        case .decrementButtonTapped:
//          print("CounterReducerProtocol: ", action)
//          state.count -= 1
//          return .none
//        case .incrementButtonTapped:
//          print("CounterReducerProtocol: ", action)
//          state.count += 1
//          return .none
//      }
//    }
  }
}

// MARK: CounterMiddleware
struct CounterMiddleware: MiddlewareProtocol {

  // MARK: State
  typealias State = Counter.State

  // MARK: Action
  typealias Action = Counter.Action

  // MARK: Dependency
  @Dependency(\.uuid) var uuid

  // MARK: Body
  var body: some MiddlewareProtocolOf<Self> {
    // MARK: Middleware
    Middleware { action, source, state in
      let io = IO<Counter.Action> { output in
        print("state:",state)
        switch action {
          case .decrementButtonTapped:
            print("CounterMiddleware:", action)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
              output.dispatch(.decrementButtonTapped)
            }
          case .incrementButtonTapped:
            print("CounterMiddleware:", action)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
              output.dispatch(.incrementButtonTapped)
            }
        }
      }
      return io
    }

    // MARK: EffectMiddleware
//    EffectMiddleware { action, source, state in
//      print("state:", state)
//      switch action {
//        case .decrementButtonTapped:
//          print("CounterEffectMiddleware:", action)
//          return EffectTask(value: .decrementButtonTapped)
//            .delay(for: 1, scheduler: UIScheduler.shared)
//            .eraseToEffect()
//        case .incrementButtonTapped:
//          print("CounterEffectMiddleware:", action)
//          return EffectTask(value: .incrementButtonTapped)
//            .delay(for: 1, scheduler: UIScheduler.shared)
//            .eraseToEffect()
//      }
//    }
    // MARK: AsyncMiddleware
//    AsyncMiddleware { action, source, state in
//      print("state:",state)
//      switch action {
//        case .decrementButtonTapped:
//          print("CounterAsyncMiddleware:", action)
//          try await Task.sleep(nanoseconds: 1_000_000_000)
//          return .decrementButtonTapped
//        case .incrementButtonTapped:
//          print("CounterAsyncMiddleware:", action)
//          try await Task.sleep(nanoseconds: 1_000_000_000)
//          return .incrementButtonTapped
//      }
//    }
  }
}

// MARK: CounterView
struct CounterView: View {
  let store: StoreOf<Counter>
  
  @ObservedObject var viewStore: ViewStoreOf<Counter>
  
  init(store: StoreOf<Counter>) {
    self.store = store
    self.viewStore = ViewStoreOf<Counter>(store)
  }
  
  var body: some View {
    ScrollView {
      VStack {
        Text("viewStore send")
        HStack {
          Button {
            viewStore.send(.decrementButtonTapped)
          } label: {
            Image(systemName: "minus")
          }
          Text("\(viewStore.count)")
            .monospacedDigit()
          Button {
            viewStore.send(.incrementButtonTapped)
          } label: {
            Image(systemName: "plus")
          }
        }
      }
      .padding()
      
      VStack {
        Text("viewStore dispatch")
        HStack {
          Button {
            viewStore.dispatch(.decrementButtonTapped)
          } label: {
            Image(systemName: "minus")
          }
          Text("\(viewStore.count)")
            .monospacedDigit()
          Button {
            viewStore.dispatch(.incrementButtonTapped)
          } label: {
            Image(systemName: "plus")
          }
        }
      }
      .padding()
      
      VStack {
        Text("store dispatch")
        HStack {
          Button {
            store.dispatch(.decrementButtonTapped)
          } label: {
            Image(systemName: "minus")
          }
          Text("\(viewStore.count)")
            .monospacedDigit()
          Button {
            store.dispatch(.incrementButtonTapped)
          } label: {
            Image(systemName: "plus")
          }
        }
      }
      .padding()
    }
  }
}

struct CounterDemoView: View {
  let store: StoreOf<Counter>
  
  var body: some View {
    CounterView(store: store)
  }
}

// MARK: - SwiftUI previews

struct CounterView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      CounterDemoView(
        store: Store(
          initialState: Counter.State(),
          reducer: Counter()
        )
        .withMiddleware(CounterMiddleware())
      )
    }
  }
}
