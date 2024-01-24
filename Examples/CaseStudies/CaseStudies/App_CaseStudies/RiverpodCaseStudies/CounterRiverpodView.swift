import SwiftUI

fileprivate class Counter: StateProvider<Int> {
  
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

fileprivate let counter = Counter()

struct ListCounterRiverpodView: View {
  var body: some View {
    List {
      ForEach(1..<3) { _ in
        CounterRiverpodView()
      }
    }
    .navigationBarTitle(Text("Riverpod Counter"), displayMode: .inline)
  }
}

struct CounterRiverpodView: ConsumerWidget {
  
  @State var countState = 0
  
  func build(context: Context, ref: ViewRef) -> any View {
    let count = ref.watch(counter)
    print(count.description)
    return HStack {
      Button {
//        counter.decrement()
        ref.update(node: counter, newValue: count - 1)
      } label: {
        Text("-")
      }
      Text(count.description)
      Button {
//        counter.increment()
        ref.update(node: counter, newValue: count + 1)
      } label: {
        Text("+")
      }
    }
    .padding()
    .font(.largeTitle)
//    .onTap {
//      ref.refresh()
//    }
  }
}

#Preview {
  CounterRiverpodView()
}
