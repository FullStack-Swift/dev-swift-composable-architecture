import SwiftUI

// MARK: ValueAtom
private struct _ValueAtom: ValueAtom, Hashable {
  func value(context: Context) -> Locale {
    .current
  }
}

private struct _ValueAtomView: View {
  @Watch(_ValueAtom())
  private var locale
  
  var body: some View {
    let _ = log.info("Refresh")
    HStack {
      Text("Locale Current")
      Spacer()
      Text(locale.identifier)
    }
  }
}

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

private struct _StateAtomView: View {
  @WatchState(_StateAtom(id: "1"))
  private var state_1
  
  @WatchState(_StateAtom(id: "2"))
  private var state_2
  
  @WatchState(_StateAtom(id: "3"))
  private var state_3
  
  var body: some View {
    VStack {
      let _ = log.info("Refresh")
      HStack {
        AtomRowTextValue(state_1)
        Stepper("Count: \(state_1)", value: $state_1)
          .labelsHidden()
      }
      HStack {
        AtomRowTextValue(state_2)
        Stepper("Count: \(state_2)", value: $state_2)
          .labelsHidden()
      }
      HStack {
        AtomRowTextValue(state_3)
        Stepper("Count: \(state_3)", value: $state_3)
          .labelsHidden()
      }
    }
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
private struct _TaskAtomView: View {
  
  @Watch(_TaskAatom(id: "_TaskAatom"))
  private var taskAtom
  
  @Watch(_StateAtom(id: "_TaskAatom"))
  private var stateAtom
  
  @ViewContext
  private var context
  
  var body: some View {
    let _ = log.info("Refresh")
    HStack {
      Suspense(taskAtom) { value in
        Text(value)
      } loading: {
        ProgressView()
      }
      Spacer()
      AtomRowTextValue(stateAtom)
      Button("Next") {
        Task {
          await context.refresh(_TaskAatom(id: "_TaskAatom"))
        }
      }
    }
    .frame(height: 60)
    .onAppear {
      _TaskAatom.value = "Swift"
    }
  }
}

// MARK: ThrowingTaskAtom
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

private struct _ThrowingTaskAtomView: View {
  
  @Watch(_ThrowingTaskAtom())
  private var throwingTaskAtom
  
  @ViewContext
  private var context
  
  var body: some View {
    let _ = log.info("Refresh")
    HStack {
      Suspense(throwingTaskAtom) { value in
        Text(value.formatted(date: .numeric, time: .shortened))
      } loading: {
        ProgressView()
      } catch: { error in
        Text((error as? _ThrowingTaskAtom.DateError)?.id ?? "")
      }
      Spacer()
      Button("Refresh") {
        Task {
          await context.refresh(_ThrowingTaskAtom())
        }
      }
    }
  }
}
// MARK: AsyncSequenceAtom

private struct _AsyncSequenceAtom: AsyncSequenceAtom, Hashable {
  func sequence(context: Context) -> AsyncStream<String> {
    return Timer.publish(every: 1, on: .main, in: .common)
      .autoconnect()
      .prepend(Date())
      .map({$0.description})
      .ignoreError()
      .values
//    AsyncStream<String> { continuation in
//      Task {
//        try await Task.sleep(for: .seconds(1))
//        continuation.yield("Swift")
//      }
//    }
  }
}

private struct _AsyncSequenceAtomView: View {
  
  @Watch(_AsyncSequenceAtom())
  private var asyncSequenceAtom
  
  @ViewContext
  private var context
  var body: some View {
    let _ = log.info("Refresh")
    switch asyncSequenceAtom {
      case .pending, .running:
        ProgressView()
      case .success(let value):
        Text(value.description)
      case .failure(let error):
        Text(error.localizedDescription)
    }
    //    Suspense(asyncSequenceAtom) { value in
    //      Text(value)
    //    } suspending: {
    //      ProgressView()
    //    } catch: { error in
    //      Text(error.localizedDescription)
    //    }
  }
}

import Combine
// MARK: PublisherAtom
private struct _PublisherAtom: PublisherAtom, Hashable {
  
  struct DateError: Error {
    var id: String
  }
  
  func publisher(context: Context) -> AnyPublisher<Date,DateError> {
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

private struct _PublisherAtomView: View {
  @Watch(_PublisherAtom())
  private var publisherAtom
  
  @ViewContext
  private var context
  
  var body: some View {
    let _ = log.info("Refresh")
    HStack {
      AsyncPhaseView(publisherAtom) { value in
        Text(value.formatted(date: .numeric, time: .shortened))
      } loading: {
        ProgressView()
      } catch: { error in
        Text(error.id)
      }
      Spacer()
      Button("Refresh") {
        Task {
          await context.refresh(_PublisherAtom())
        }
      }
    }
    
  }
}
// MARK: ObservableObjectAtom
private class _ObservableObject: ObservableObject {
  @Published var name = ""
  @Published var age = 0
  
  func plus() {
    age += 1
  }
  
  func minus() {
    age -= 1
  }
}

private struct _ObservableObjectAtom: ObservableObjectAtom, Hashable {
  func object(context: Context) -> _ObservableObject {
    _ObservableObject()
  }
}

private struct _ObservableObjectAtomView: View {
  @WatchStateObject(_ObservableObjectAtom())
  private var viewModel
  
  var body: some View {
    let _ = log.info("Refresh")
    VStack {
      TextField("Enter your name", text: $viewModel.name)
      Text("Name: \(viewModel.name), Age: \(viewModel.age)")
      HStack {
        Button {
          viewModel.minus()
        } label: {
          ImageMinus()
        }
        
        Button {
          viewModel.plus()
        } label: {
          ImagePlus()
        }
      }
      .padding()
      .fixedSize()
    }
  }
}

struct AtomCaseStudiesView: View {
  var body: some View {
    Form {
      Section(header: Text("Use Case")) {
        
        NavigationLink("PropertyWrapper") {
          AtomLocalViewContextView()
        }
        
        NavigationLink("PropertyWrapper") {
          AtomLocalViewContextView()
        }
        
        NavigationLink("PropertyWrapper") {
          AtomLocalViewContextView()
        }
      }
    }
  }
}


//struct AtomCaseStudiesView: View {
//  
//  var body: some View {
//    let _ = log.info("Refresh")
//    ZStack {
//      ScrollView {
//        VStack(spacing: 8) {
//          AtomRowView("_ValueAtom") {
//            _ValueAtomView()
//          }
//          AtomRowView("_StateAtom") {
//            _StateAtomView()
//          }
//          AtomRowView("_TaskAtom") {
//            _TaskAtomView()
//          }
//          AtomRowView("_ThrowingTaskAtom") {
//            _ThrowingTaskAtomView()
//          }
//          AtomRowView("_AsyncSequenceAtom") {
//            _AsyncSequenceAtomView()
//          }
//          AtomRowView("_PublisherAtom") {
//            _PublisherAtomView()
//          }
//          AtomRowView("_ObservableObjectAtom") {
//            _ObservableObjectAtomView()
//          }
//        }
//        .padding()
//      }
//#if os(iOS)
//      .background(Color(.systemBackground).ignoresSafeArea())
//      .navigationBarTitle(Text("Atom"), displayMode: .inline)
//#endif
//    }
//  }
//}

private struct AtomRowView<Content: View>: View {
  let title: String
  let content: Content
  
  init(_ title: String, @ViewBuilder content: () -> Content) {
    self.title = title
    self.content = content()
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(title)
        .font(.system(size: 16, weight: .regular, design: .serif))
      HStack(alignment: .center) {
        content
      }
      .padding(.vertical, 16)
      Divider()
    }
    .padding(.horizontal, 24)
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

private struct ImagePlus: View {
  var body: some View {
    Image(systemName: "plus")
      .bold()
      .foregroundColor(.accentColor)
  }
}

private struct ImageMinus: View {
  var body: some View {
    Image(systemName: "minus")
      .bold()
      .foregroundColor(.accentColor)
  }
}

#Preview {
  AtomRoot {
    AtomCaseStudiesView()
  }
}
