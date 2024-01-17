import SwiftUI
import Combine

struct RiverpodCaseStudiesView: View {
  
  var body: some View {
    Form {
      Section(header: Text("Use Case")) {
        NavigationLink("Riverpod Counter") {
          ListCounterRiverpodView()
        }
      }
    }
#if os(iOS)
    .navigationBarTitle(Text("Riverpod"), displayMode: .inline)
    .navigationBarItems(leading: leading, trailing: trailing)
#endif
  }
  
  var leading: some View {
    EmptyView()
  }
  
  var trailing: some View {
    EmptyView()
  }
}

#Preview {
  RiverpodCaseStudiesView()
}
//
//fileprivate class Counter: StateProvider<Int> {
//
//  init() {
//    super.init(0)
//  }
//
//  func increment() {
//    value += 1
//  }
//
//  func decrement() {
//    value -= 1
//  }
//}
//
//fileprivate let counter = Counter()
//
//// A shared state that can be accessed by multiple
//// objects at the same time
//fileprivate let counterProvider = StateNotifierProvider<Counter> {
//  counter
//}
//
//class _FutureProvider: FutureProvider<AnyPublisher<String, Never>> {
//  
//  let current = CurrentValueSubject<Int, Never>(0)
//  
//  init() {
//    super.init { [current] in
//      current
//        .map(\.description)
//        .delay(for: 1, scheduler: UIScheduler.shared)
//        .eraseToAnyPublisher()
//    }
//  }
//  
//  override func refresh() {
//    current.value += 1
//    super.refresh()
//  }
//}
//
//let futureProvider = _FutureProvider()
//
//private struct _CounterView: ConsumerWidget {
//  
//  let counterProvider = StateNotifierProvider<Counter> {
//    counter
//  }
//  
//  let publisherProvider = StateNotifierProvider<_FutureProvider> {
//    futureProvider
//  }
//  
//  func build(context: Context, ref: ViewRef) -> some View {
//    VStack {
//      HStack {
////        let phase = ref.watch(futureProvider)
//        let phase = ref.watch(publisherProvider)
//        AsyncPhaseView(phase) { text in
//          Text(text)
//            .font(.largeTitle)
//        } loading: {
//          ProgressView()
//        }
//      }
//      .onTapGesture {
//        publisherProvider.state.refresh()
////        futureProvider.refresh()
//      }
//      HStack {
//        Button("+") {
//          counter.value += 1
//        }
//        Text(ref.watch(counterProvider).description)
//        Button("-") {
//          counter.value += 1
//        }
//      }
//      .font(.largeTitle)
//      .foregroundColor(.accentColor)
//      HStack {
//        Button("+") {
//          counter.increment()
//        }
//        Text(ref.watch(counterProvider).description)
//        Button("-") {
//          counter.decrement()
//        }
//      }
//      .font(.largeTitle)
//      .foregroundColor(.accentColor)
//      HStack {
//        Button("+") {
//          counterProvider.state.increment()
//        }
//        Text(ref.watch(counterProvider).description)
//        Button("-") {
//          counterProvider.state.decrement()
//        }
//      }
//      .font(.largeTitle)
//      .foregroundColor(.accentColor)
//    }
//    .onAppear {
//      futureProvider.refresh()
//    }
//  }
//}
