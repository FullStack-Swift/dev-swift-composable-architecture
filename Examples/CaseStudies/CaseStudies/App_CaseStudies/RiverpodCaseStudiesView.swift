import SwiftUI
import ComposableArchitecture
import Combine

struct RiverpodCaseStudiesView: View {
  
  var body: some View {
    ScrollView {
      Group {
        Text("Riverpod Pro")
        _CounterView()
        _CounterView()
        _CounterView()
        Divider()
      }
    }
    .padding()
    .navigationBarTitle(Text("Riverpod"), displayMode: .inline)
    .navigationBarItems(leading: leading, trailing: trailing)
  }
  
  var leading: some View {
    EmptyView()
  }
  
  var trailing: some View {
    EmptyView()
  }
}

struct RiverpodCaseStudiesView_Previews: PreviewProvider {
  static var previews: some View {
    RiverpodCaseStudiesView()
  }
}

class Counter: StateProvider<Int> {

  init() {
    super.init(0)
  }

  func increment() {
    value += 1
  }

  func decrement() {
    value -= 1
  }

}

let counter = Counter()

// A shared state that can be accessed by multiple
// objects at the same time
let counterProvider = StateNotifierProvider<Counter> {
  counter
}


// Consumes the shared state and rebuild when it changes
private struct _CounterView: ConsumerView {
  
  class Counter: StateProvider<Int> {
    
    init() {
      super.init(0)
    }
    
    func increment() {
      value += 1
    }
    
    func decrement() {
      value -= 1
    }
    
  }
  
  class _FutureProvider: FutureProvider<AnyPublisher<String, Never>> {
    
    let current = CurrentValueSubject<Int, Never>(0)
    
    init() {
      super.init { [current] in
        current
          .map(\.description)
          .delay(for: 1, scheduler: UIScheduler.shared)
          .eraseToAnyPublisher()
      }
    }
    
    override func refresh() {
      current.value += 1
      super.refresh()
    }
  }
  
  let counter = Counter()
  
  let futureProvider = _FutureProvider()
  
  func build(context: Context, ref: ViewRef) -> some View {
    // A shared state that can be accessed by multiple
    // objects at the same time
    let counterProvider = StateNotifierProvider<Counter> {
      counter
    }
    
    let publisherProvider = StateNotifierProvider<_FutureProvider> {
      futureProvider
    }

    VStack {
      HStack {
        let phase = ref.watch(futureProvider)
//        let phase = ref.watch(publisherProvider)
        AsyncPhaseView(phase: phase) { text in
          Text(text)
            .font(.largeTitle)
        } suspending: {
          ProgressView()
        }
      }
      .onTapGesture {
        publisherProvider.state.refresh()
//        futureProvider.refresh()
      }
      HStack {
        Button("+") {
          counter.value += 1
        }
        Text(ref.watch(counterProvider).description)
          .font(.largeTitle)
        Button("-") {
          counter.value += 1
        }
      }
      .foregroundColor(.accentColor)
      HStack {
        Button("+") {
          counter.increment()
        }
        Text(ref.watch(counterProvider).description)
          .font(.largeTitle)
        Button("-") {
          counter.decrement()
        }
      }
      .foregroundColor(.accentColor)
      HStack {
        Button("+") {
          counterProvider.state.increment()
        }
        Text(ref.watch(counterProvider).description)
          .font(.largeTitle)
        Button("-") {
          counterProvider.state.decrement()
        }
      }
      .foregroundColor(.accentColor)
    }
  }
}
