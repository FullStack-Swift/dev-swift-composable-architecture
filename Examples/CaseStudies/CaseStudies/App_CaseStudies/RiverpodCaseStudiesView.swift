import SwiftUI
import ComposableArchitecture
import Combine

// MARK: StateAtom
private struct _StateAtom: StateAtom, Hashable {
  
  var id: String
  
  init(id: String = "") {
    self.id = id
  }
  
  func defaultValue(context: Context) -> Int {
    0
  }
  
  var key: any Hashable {
    id
  }
}

// MARK: ValueAtom
private struct _ValueAtom: ValueAtom, Hashable {
  
  var id: String
  
  func value(context: Context) -> Int {
    context.watch(_StateAtom(id: id))
  }
}

struct _RecoilViewContext: View {
    
  var body: some View {
    HookScope {
      VStack {
        HookScope {
          HStack {
            let state = useRecoilState(_StateAtom(id: "1"))
            let value = useRecoilValue(_ValueAtom(id: "1"))
            AtomRowTextValue(state.wrappedValue)
            AtomRowTextValue(value)
            Stepper("Count: \(state.wrappedValue)", value: state)
              .labelsHidden()
          }
        }
        HookScope {
          HStack {
            let state = useRecoilState(_StateAtom(id: "1"))
            let value = useRecoilValue(_ValueAtom(id: "1"))
            AtomRowTextValue(state.wrappedValue)
            AtomRowTextValue(value)
            Stepper("Count: \(state.wrappedValue)", value: state)
              .labelsHidden()
          }
        }
      }
    }
  }
}

struct _ProviderGlobalView: ProviderGlobalView {
    
  func build(context: Context, ref: ViewRef) -> some View {
    VStack {
      HookScope {
        HStack {
          let state = context.useRecoilState(_StateAtom(id: "1"))
          let value = context.useRecoilValue(_ValueAtom(id: "1"))
          AtomRowTextValue(state.wrappedValue)
          AtomRowTextValue(value)
          Stepper("Count: \(state.wrappedValue)", value: state)
            .labelsHidden()
        }
      }
      HookScope {
        HStack {
          let state = context.useRecoilState(_StateAtom(id: "1"))
          let value = context.useRecoilValue(_ValueAtom(id: "1"))
          AtomRowTextValue(state.wrappedValue)
          AtomRowTextValue(value)
          Stepper("Count: \(state.wrappedValue)", value: state)
            .labelsHidden()
        }
      }
    }
  }
}

struct _ProviderLocalView: ProviderLocalView {
  
  func build(context: Context, ref: ViewRef) -> some View {
    VStack {
      HookScope {
        HStack {
          let state = context.useRecoilState(_StateAtom(id: "1"))
          let value = context.useRecoilValue(_ValueAtom(id: "1"))
          AtomRowTextValue(state.wrappedValue)
          AtomRowTextValue(value)
          Stepper("Count: \(state.wrappedValue)", value: state)
            .labelsHidden()
        }
      }
      HookScope {
        HStack {
          let state = context.useRecoilState(_StateAtom(id: "1"))
          let value = context.useRecoilValue(_ValueAtom(id: "1"))
          AtomRowTextValue(state.wrappedValue)
          AtomRowTextValue(value)
          Stepper("Count: \(state.wrappedValue)", value: state)
            .labelsHidden()
        }
      }
    }
  }
}

struct _ViewContext: View {
  
  @ViewContext
  var context
  
  var body: some View {
    HookScope {
      VStack {
        HookScope {
          HStack {
            let state = context.useRecoilState(_StateAtom(id: "1"))
            let value = context.useRecoilValue(_ValueAtom(id: "1"))
            AtomRowTextValue(state.wrappedValue)
            AtomRowTextValue(value)
            Stepper("Count: \(state.wrappedValue)", value: state)
              .labelsHidden()
          }
        }
        HookScope {
          HStack {
            let state = context.state(_StateAtom(id: "1"))
            let value = context.watch(_ValueAtom(id: "1"))
            AtomRowTextValue(state.wrappedValue)
            AtomRowTextValue(value)
            Stepper("Count: \(state.wrappedValue)", value: state)
              .labelsHidden()
          }
        }
      }
    }
  }
}

struct _LocalViewContext: View {
  
  @LocalViewContext
  var context
  
  var body: some View {
    HookScope {
      VStack {
        HookScope {
          HStack {
            let state = context.useRecoilState(_StateAtom(id: "1"))
            let value = context.useRecoilValue(_ValueAtom(id: "1"))
            AtomRowTextValue(state.wrappedValue)
            AtomRowTextValue(value)
            Stepper("Count: \(state.wrappedValue)", value: state)
              .labelsHidden()
          }
        }
        HookScope {
          HStack {
            let state = context.state(_StateAtom(id: "1"))
            let value = context.watch(_ValueAtom(id: "1"))
            AtomRowTextValue(state.wrappedValue)
            AtomRowTextValue(value)
            Stepper("Count: \(state.wrappedValue)", value: state)
              .labelsHidden()
          }
        }
      }
    }
  }
}


private struct AtomRowTextValue: View {
  
  private let content: Int
  
  init(_ content: Int) {
    self.content = content
  }
  
  var body: some View {
    GeometryReader { proxy in
      ZStack(alignment: .center) {
        Color.white.opacity(0.0001)
        HStack {
          Text(String(format: "%02d", content))
            .lineLimit(1)
            .minimumScaleFactor(0.1)
            .font(.system(size: 16, weight: .heavy, design: .monospaced))
            .padding(8)
            .background(Color.secondary.opacity(1/3))
            .clipShape(RoundedRectangle(cornerRadius: proxy.size.height))
            .foregroundColor(.primary)
          Spacer()
        }
      }
    }
  }
}

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
      Group {
        Text("Global Context")
        _ProviderGlobalView()
        _ProviderGlobalView()
        _ProviderGlobalView()
        Divider()
      }

      Group {
        Text("Local Context")
        _ProviderLocalView()
        _ProviderLocalView()
        _ProviderLocalView()
        Divider()
      }
      Group {
        Text("Global ViewContext")
        _ViewContext()
        _ViewContext()
        _ViewContext()
        Divider()
      }
      Group {
        Text("Local ViewContext")
        _LocalViewContext()
        _LocalViewContext()
        _LocalViewContext()
        Divider()
      }
      
      Group {
        Text("Recoil")
        _RecoilViewContext()
        _RecoilViewContext()
        _RecoilViewContext()
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

//class Counter: StateProvider<Int> {
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
//
//}
//
//let counter = Counter()
//
//// A shared state that can be accessed by multiple
//// objects at the same time
//let counterProvider = StateNotifierProvider<Int, Counter> {
//  counter
//}


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
//        let phase = ref.watch(futureProvider)
        let phase = ref.watch(publisherProvider)
        AsyncPhaseView(phase: phase) { text in
          Text(text)
            .font(.largeTitle)
        } suspending: {
          ProgressView()
        }
      }
      .onTapGesture {
//        publisherProvider.state.refresh()
        futureProvider.refresh()
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
