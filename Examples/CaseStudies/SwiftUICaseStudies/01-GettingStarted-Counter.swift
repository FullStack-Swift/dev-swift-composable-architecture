import ComposableArchitecture
import SwiftUI

// MARK: - Feature domain

struct Counter: ReducerProtocol {
  struct State: Equatable {
    var count = 0
  }
  
  enum Action: Equatable {
    case decrementButtonTapped
    case incrementButtonTapped
  }
  
  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
      case .decrementButtonTapped:
        print("CounterReducerProtocol: ", action)
        state.count -= 1
        return .none
      case .incrementButtonTapped:
        print("CounterReducerProtocol: ", action)
        state.count += 1
        return .none
    }
  }
}

struct CounterMiddleware: MiddlewareProtocol {
  func handle(action: Counter.Action, from dispatcher: ActionSource, state: @escaping GetState<Counter.State>) -> IO<Counter.Action> {
    print(dispatcher)
    print("old_state:",state())
    let io = IO<Counter.Action> { output in
      print("new_state:",state())
      switch action {
        case .decrementButtonTapped:
          print("CounterMiddleware:", action)
        case .incrementButtonTapped:
          print("CounterMiddleware:", action)
      }
    }
    return io
  }
}

// MARK: - Feature view

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
