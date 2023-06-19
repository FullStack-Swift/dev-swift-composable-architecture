import SwiftUI
import ComposableArchitecture

// MARK: ValueAtom
private struct _ValueAtom: ValueAtom, Hashable {
  func value(context: Context) -> Locale {
    .current
  }
}

private struct _ValueAtomView: View {
  @Watch(_ValueAtom())
  var locale

  var body: some View {
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
  var state_1

  @WatchState(_StateAtom(id: "2"))
  var state_2

  @WatchState(_StateAtom(id: "3"))
  var state_3

  var body: some View {
    VStack {
      Stepper("Count: \(state_1)", value: $state_1)
      Stepper("Count: \(state_2)", value: $state_2)
      Stepper("Count: \(state_3)", value: $state_3)
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
    HStack {
      Suspense(taskAtom) { value in
        Text(value)
      } suspending: {
        ProgressView()
      }
      Spacer()
      Text("count: \(stateAtom)")
      Button("Next") {
        Task {
          await context.refresh(_TaskAatom(id: "_TaskAatom"))
        }
      }
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
  var context

  var body: some View {
    HStack {
      Suspense(throwingTaskAtom) { value in
        Text(value.formatted(date: .numeric, time: .shortened))
      } suspending: {
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
private struct _AsyncSequenceAtom: View {

  var body: some View {
    EmptyView()
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
    HStack {
      AsyncPhaseView(phase: publisherAtom) { value in
        Text(value.formatted(date: .numeric, time: .shortened))
      } suspending: {
        ProgressView()
      } failureContent: { error in
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
  @Published var name = "Swift"
  @Published var age = 5

  func haveBirthday() {
    age += 1
  }
}

private struct _ObservableObjectAtom: ObservableObjectAtom, Hashable {
  func object(context: Context) -> _ObservableObject {
    _ObservableObject()
  }
}

struct _ObservableObjectAtomView: View {
  @WatchStateObject(_ObservableObjectAtom())
  fileprivate var contact

  var body: some View {
    VStack {
      TextField("Enter your name", text: $contact.name)
      Text("Name: \(contact.name), Age: \(contact.age)")
      Button("Celebrate your birthday!") {
        contact.haveBirthday()
      }
    }
  }
}


struct AtomView: View {

  var body: some View {
    ScrollView {
      VStack(spacing: 8) {
        _ValueAtomView()
        _StateAtomView()
        _TaskAtomView()
        _ThrowingTaskAtomView()
        _AsyncSequenceAtom()
        _PublisherAtomView()
        _ObservableObjectAtomView()
      }
      .padding()
      Spacer()
    }
  }
}

struct AtomView_Previews: PreviewProvider {
  static var previews: some View {
    AtomRoot {
      AtomView()
    }
  }
}

