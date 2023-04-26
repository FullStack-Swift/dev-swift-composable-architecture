import ComposableArchitecture
import SwiftUI

private let readMe = """
  This screen demonstrates the basics of the Composable Architecture in an archetypal counter \
  application.
  
  The domain of the application is modeled using simple data types that correspond to the mutable \
  state of the application and any actions that can affect that state or the outside world.
  """

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
        state.count -= 1
        return .none
      case .incrementButtonTapped:
        state.count += 1
        return .none
    }
  }
}

struct CounterMiddleware: MiddlewareProtocol {
  func handle(action: Counter.Action, from dispatcher: ActionSource, state: @escaping GetState<Counter.State>) -> IO<Counter.Action> {
    print(state())
    let io = IO<Counter.Action> { output in
      print(state())
      switch action {
        case .decrementButtonTapped:
          print(action)
        case .incrementButtonTapped:
          print(action)
      }
    }
    return io
  }
}

// MARK: - Feature view

struct CounterView: View {
  let store: StoreOf<Counter>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      HStack {
        Button {
          //          viewStore.send(.decrementButtonTapped)
          store.dispatch(.init(.decrementButtonTapped, dispatcher: .here()))
        } label: {
          Image(systemName: "minus")
        }
        
        Text("\(viewStore.count)")
          .monospacedDigit()
        
        Button {
          //          viewStore.send(.incrementButtonTapped)
          store.dispatch(.init(.incrementButtonTapped, dispatcher: .here()))
        } label: {
          Image(systemName: "plus")
        }
      }
    }
  }
}

struct CounterDemoView: View {
  let store: StoreOf<Counter>
  
  var body: some View {
    Form {
      Section {
        AboutView(readMe: readMe)
      }
      
      Section {
        CounterView(store: self.store)
          .frame(maxWidth: .infinity)
      }
    }
    .buttonStyle(.borderless)
    .navigationTitle("Counter demo")
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
