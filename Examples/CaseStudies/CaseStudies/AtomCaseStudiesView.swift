import SwiftUI
import ComposableArchitecture

struct CounterAtom: StateAtom, Hashable {
  func defaultValue(context: Context) -> Int {
    0
  }
}

struct AtomCaseStudiesView: View {
  @Watch(CounterAtom())
  var count

  var body: some View {
    VStack {
      Text("Count: \(count)").font(.largeTitle)
      CountStepper()
    }
    .fixedSize()
    .navigationTitle("Counter")
  }
}

struct CountStepper: View {
  @WatchState(CounterAtom())
  var count

  var body: some View {
#if os(tvOS) || os(watchOS)
    HStack {
      Button("-") { count -= 1 }
      Button("+") { count += 1 }
    }
#else
    Stepper(value: $count) {}
      .labelsHidden()
#endif
  }
}

struct AtomCaseStudiesView_Previews: PreviewProvider {
    static var previews: some View {
        AtomCaseStudiesView()
    }
}
