import SwiftUI
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
  
  var key: any Hashable {
    id
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
  
  func value(context: Context) async -> String {
    try? await Task.sleep(nanoseconds: 1_000_000_000)
    context.set(Int.random(in: 1..<1000), for: _StateAtom(id: "_TaskAatom"))
    return Bool.random() ? "Swift" : "ObjectiveC"
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
  
  var key: Self {
    self
  }
}

private struct _StateAtomView: HookView {

  @MainActor
  var hookBody: some View {
    HookScope {
      VStack {
        // MARK: useRecoilRefresher
        VStack {
          let (phase,refresh) = useRecoilRefresher(_PublisherAtom(id: "useRecoilRefresher"))
          AsyncPhaseView(phase) { value in
            HStack {
              Text(value.timeIntervalSince1970.description)
            }
            
          } loading: {
            ProgressView()
          } catch: { error in
            Text(error.localizedDescription)
          }
          .frame(height: 60)
          .onFirstAppear {
            refresh()
          }
          .onTapGesture {
            refresh()
          }
        }
        
        // MARK: useRecoilPublisher
        VStack {
          let phase = useRecoilPublisher(_PublisherAtom(id: "_useRecoilRefresher"))
          AsyncPhaseView(phase) { value in
            Text(value.timeIntervalSince1970.description)
          } loading: {
            ProgressView()
          } catch: { error in
            Text(error.localizedDescription)
          }
          .frame(height: 60)
        }
        // MARK: useRecoilTask
        HookScope {
          VStack {
            let phase = useRecoilTask(updateStrategy: .once, _TaskAatom(id: "1"))
            AsyncPhaseView(phase) { value in
              logChanges(value)
              Text(value)
                .lineLimit(nil)
            } loading: {
              ProgressView()
            }
            .frame(height: 60)
          }
        }
        // MARK: useRecoilThrowingTask
        VStack {
          let phase = useRecoilThrowingTask(updateStrategy: .once, _ThrowingTaskAtom())
          AsyncPhaseView(phase) { value in
            Text(value.timeIntervalSince1970.description)
          } loading: {
            ProgressView()
          } catch: { error in
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
  
  @MainActor
  var headerView: some View {
    HookScope {
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
}

private struct _RecoilLocalScope: View {
  
  var body: some View {
    RecoilLocalScope { localViewContext in
      HStack {
        let state = localViewContext.useRecoilState(_StateAtom(id: "1"))
        let value = localViewContext.useRecoilValue(_ValueAtom(id: "1"))
        AtomRowTextValue(state.wrappedValue)
        AtomRowTextValue(value)
        Stepper("Count: \(state.wrappedValue)", value: state)
          .labelsHidden()
      }
    }
  }
}

private struct _RecoilGlobalScope: View {
  
  var body: some View {
    RecoilGlobalScope { globalViewContext in
      HStack {
        let state = globalViewContext.useRecoilState(_StateAtom(id: "1"))
        let value = globalViewContext.useRecoilValue(_ValueAtom(id: "1"))
        AtomRowTextValue(state.wrappedValue)
        AtomRowTextValue(value)
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
      // MARK: ViewContext
      Group {
        Section("ViewContext") {
          _StateAtomView()
        }
        .padding()
        
        Section("Other ViewContext") {
          _StateAtomView()
        }
        .padding()
      }
      
      // MARK: Local
      Group {
        Section("func recoilBody(context: RecoilLocalContext)") {
          _RecoilLocalView()
        }
        .padding()
        
        Section("func recoilBody(context: RecoilLocalContext)") {
          _RecoilLocalView()
        }
        .padding()
        
        Section("RecoilLocalScope { localViewContext in") {
          _RecoilLocalScope()
        }
        .padding()
        
        Section("RecoilLocalScope { localViewContext in") {
          _RecoilLocalScope()
        }
        .padding()
      }
      
      // MARK: Global
      Group {
        Section("func recoilBody(context: RecoilGlobalContext)") {
          _RecoilGlobalView()
        }
        .padding()
        
        Section("func recoilBody(context: RecoilGlobalContext)") {
          _RecoilGlobalView()
        }
        .padding()
        
        Section("RecoilGlobalScope { globalViewContext in") {
          _RecoilGlobalScope()
        }
        .padding()
        
        Section("RecoilGlobalScope { globalViewContext in") {
          _RecoilGlobalScope()
        }
        .padding()
      }
      
      // MARK: Other
      Group {
        Section("Other") {
          RecoilUseCaseStudies2View()
        }
        .padding()
      }
    }
    .listStyle(.sidebar)
#if os(iOS)
    .navigationBarTitle(Text("Recoil"), displayMode: .inline)
#endif
  }
}

