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
  
  func build(context: Context, ref: ViewRef) -> some View {
    VStack {
      Stepper(value: ref.binding(counter)) {
        Text(counter.value.description)
      }
    }
    .padding()
    .font(.largeTitle)
    .onTap {
      ref.refresh()
    }
  }
}

#Preview {
  CounterRiverpodView()
}
