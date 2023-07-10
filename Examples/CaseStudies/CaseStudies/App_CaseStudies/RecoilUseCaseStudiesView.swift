import SwiftUI
import Combine
import ComposableArchitecture

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


// MARK: TaskAtom
private struct _TaskAatom: TaskAtom, Hashable {
  
  var id: String
  
  init(id: String) {
    self.id = id
  }
  
  var value: String {
    return UUID().uuidString
  }
  
  static var value: String = "Swift"
  
  func value(context: Context) async -> String {
    try? await Task.sleep(nanoseconds: 1_000_000_000)
    Self.value += "_@"
    context.set(Self.value.count, for: _StateAtom(id: "_TaskAatom"))
    return Self.value
  }
}

private struct _ThrowingTaskAtom: ThrowingTaskAtom, Hashable {
  struct DateError: Error {
    var id: String
  }
  func value(context: Context) async throws -> Date {
    try await Task.sleep(nanoseconds: 1_000_000_000)
    if Bool.random() {
      return Date()
    } else {
      throw DateError(id: "DateError")
    }
  }
}

private struct _PublisherAtom: PublisherAtom, Hashable {
  
  struct DateError: Error {
    var id: String
  }
  
  var id: String
  
  init(id: String) {
    self.id = id
  }
  
  func publisher(context: Context) -> AnyPublisher<Date, DateError> {
    if Bool.random() {
      return Just(Date())
        .delay(for: 1, scheduler: DispatchQueue.main)
        .setFailureType(to: DateError.self)
        .eraseToAnyPublisher()
    } else {
      return Fail(error: DateError(id: "DateError"))
        .delay(for: 1, scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
  }
}

private struct _StateAtomView: HookView {
  
  @ViewContext
  private var context
  
  var hookBody: some View {
    HookScope {
      VStack {
        // MARK: useRecoilRefresher
        VStack {
          let (phase,refresh) = useRecoilRefresher(_PublisherAtom(id: "useRecoilRefresher"))
          Text("useRecoilRefresher")
            .task {
              refresh()
            }
            .onTapGesture {
              refresh()
            }
          AsyncPhaseView(phase: phase) { value in
            HStack {
              Text(value.timeIntervalSince1970.description)
            }

          } suspending: {
            ProgressView()
          } failureContent: { error in
            Text(error.localizedDescription)
          }
          .frame(height: 60)
          .onTapGesture {
            refresh()
          }
        }
        // MARK: useRecoilPublisher
        VStack {
          let phase = useRecoilPublisher(_PublisherAtom(id: "useRecoilPublisher"))
          AsyncPhaseView(phase: phase) { value in
            Text(value.timeIntervalSince1970.description)
          } suspending: {
            ProgressView()
          } failureContent: { error in
            Text(error.localizedDescription)
          }
          .frame(height: 60)
        }
        // MARK: useRecoilTask
        VStack {
          let phase = useRecoilTask(.once, _TaskAatom(id: "1"))
          AsyncPhaseView(phase: phase) { value in
            Text(value)
          } suspending: {
            ProgressView()
          }
          .frame(height: 60)
        }
        // MARK: useRecoilThrowingTask
        VStack {
          let phase = useRecoilThrowingTask(.once, _ThrowingTaskAtom())
          AsyncPhaseView(phase: phase) { value in
            Text(value.timeIntervalSince1970.description)
          } suspending: {
            ProgressView()
          } failureContent: { error in
            Text(error.localizedDescription)
          }
          
        }
        headerView
          .padding()
        HStack {
          let state = useRecoilState(_StateAtom(id: "1"))
          AtomRowTextValue(state.wrappedValue)
          Stepper("Count: \(state.wrappedValue)", value: state)
            .labelsHidden()
        }
        HStack {
          let state = useRecoilState(_StateAtom(id: "2"))
          AtomRowTextValue(state.wrappedValue)
          Stepper("Count: \(state.wrappedValue)", value: state)
            .labelsHidden()
        }
        HStack {
          let state = useRecoilState(_StateAtom(id: "3"))
          AtomRowTextValue(state.wrappedValue)
          Stepper("Count: \(state.wrappedValue)", value: state)
            .labelsHidden()
        }
      }
    }
  }
  
  var headerView: some View {
    let state1 = useRecoilValue(_StateAtom(id: "1"))
    let state2 = useRecoilValue(_StateAtom(id: "2"))
    let state3 = useRecoilValue(_StateAtom(id: "3"))
    return Text(state1.description + " + ")
      .foregroundColor(.red)
    + Text(state2.description + " + ")
      .foregroundColor(.green)
    + Text(state3.description + " = ")
      .foregroundColor(.blue)
    + Text((state1 + state2 + state3).description)
      .foregroundColor(.cyan)
  }
}

private struct _ScopeRecoilView: View {
  
  @RecoilLocalViewContext
  private var viewContext
  
  var body: some View {
    HookScope {
      HStack {
        let state = viewContext.useRecoilState(_StateAtom(id: "1"))
        let value = viewContext.useRecoilValue(_ValueAtom(id: "1"))
        AtomRowTextValue(state.wrappedValue)
        AtomRowTextValue(value)
        Stepper("Count: \(state.wrappedValue)", value: state)
          .labelsHidden()
      }
    }
  }
}

private struct _GlobalRecoilView: View {
  
  var body: some View {
    HookScope {
      HStack {
        let state = useRecoilState(_StateAtom(id: "1"))
//        let value = useRecoilValue(_ValueAtom(id: "1"))
        AtomRowTextValue(state.wrappedValue)
//        AtomRowTextValue(value)
        Stepper("Count: \(state.wrappedValue)", value: state)
          .labelsHidden()
      }
    }
  }
}

private struct _RecoilGlobalView: RecoilGlobalView {
  
  func recoilBody(context: RecoilGlobalContext) -> some View {
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

private struct _RecoilLocalView: RecoilLocalView {
  
  func recoilBody(context: RecoilLocalContext) -> some View {
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

struct RecoilUseCaseStudiesView: View {
  
  var body: some View {
    List {
      Section("ViewContext") {
        _StateAtomView()
      }
      .padding()
      
      Section("Other ViewContext") {
        _StateAtomView()
      }
      .padding()
      
      Section("Recoil Global View") {
        _RecoilGlobalView()
      }
      .padding()
      
      Section("Other Recoil Global View") {
        _RecoilGlobalView()
      }
      .padding()

      Section("Recoil Local View") {
        _RecoilLocalView()
      }
      .padding()
      
      Section("Other Recoil Local View") {
        _RecoilLocalView()
      }
      .padding()
      
      Section("Scope Recoil") {
        _ScopeRecoilView()
      }
      .padding()
      
      Section("Other Scope Recoil") {
        _ScopeRecoilView()
      }
      .padding()
      
      Section("Global Recoil") {
        _GlobalRecoilView()
      }
      .padding()
      
      Section("Other Global Recoil") {
        _GlobalRecoilView()
        HookScope {
          HStack {
//            let state = useRecoilState(_StateAtom(id: "1"))
                    let value = useRecoilValue(_ValueAtom(id: "1"))
//            AtomRowTextValue(state.wrappedValue)
                    AtomRowTextValue(value)
//            Stepper("Count: \(state.wrappedValue)", value: state)
//              .labelsHidden()
          }
        }
      }
      .padding()
    }
    .listStyle(.sidebar)
    .navigationBarTitle(Text("Recoil"), displayMode: .inline)
  }
}
