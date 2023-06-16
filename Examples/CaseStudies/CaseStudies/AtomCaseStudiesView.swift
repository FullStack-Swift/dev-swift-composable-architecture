import SwiftUI
import SwiftUIListExtension
import ComposableArchitecture

struct CounterAtom: StateAtom, Hashable {
  func defaultValue(context: Context) -> Int {
    0
  }
}

struct Todo: Hashable, Identifiable {
  var id: UUID
  var text: String
  var isCompleted: Bool
}

enum Filter: CaseIterable, Hashable {
  case all
  case completed
  case uncompleted
}

struct Stats: Equatable {
  let total: Int
  let totalCompleted: Int
  let totalUncompleted: Int
  let percentCompleted: Double
}

struct TodosAtom: StateAtom, Hashable, KeepAlive {
  func defaultValue(context: Context) -> IdentifiedArrayOf<Todo> {
    []
  }
}

struct FilterAtom: StateAtom, Hashable {
  func defaultValue(context: Context) -> Filter {
    .all
  }
}

struct FilteredTodosAtom: ValueAtom, Hashable {
  func value(context: Context) -> IdentifiedArrayOf<Todo> {
    let filter = context.watch(FilterAtom())
    let todos = context.watch(TodosAtom())

    switch filter {
      case .all:
        return todos

      case .completed:
        return todos.filter(\.isCompleted)

      case .uncompleted:
        return todos.filter { !$0.isCompleted }
    }
  }
}

struct StatsAtom: ValueAtom, Hashable {
  func value(context: Context) -> Stats {
    let todos = context.watch(TodosAtom())
    let total = todos.count
    let totalCompleted = todos.filter(\.isCompleted).count
    let totalUncompleted = todos.filter { !$0.isCompleted }.count
    let percentCompleted = total <= 0 ? 0 : (Double(totalCompleted) / Double(total))

    return Stats(
      total: total,
      totalCompleted: totalCompleted,
      totalUncompleted: totalUncompleted,
      percentCompleted: percentCompleted
    )
  }
}

struct TodoStats: View {
  @Watch(StatsAtom())
  var stats

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      stat("Total", "\(stats.total)")
      stat("Completed", "\(stats.totalCompleted)")
      stat("Uncompleted", "\(stats.totalUncompleted)")
      stat("Percent Completed", "\(Int(stats.percentCompleted * 100))%")
    }
    .padding(.vertical)
  }

  func stat(_ title: String, _ value: String) -> some View {
    HStack {
      Text(title) + Text(":")
      Spacer()
      Text(value)
    }
  }
}

struct TodoFilters: View {
  @WatchState(FilterAtom())
  var filter

  var body: some View {
    Picker("Filter", selection: $filter) {
      ForEach(Filter.allCases, id: \.self) { filter in
        switch filter {
          case .all:
            Text("All")

          case .completed:
            Text("Completed")

          case .uncompleted:
            Text("Uncompleted")
        }
      }
    }
    .padding(.vertical)

#if !os(watchOS)
    .pickerStyle(.segmented)
#endif
  }
}

struct TodoCreator: View {
  @WatchState(TodosAtom())
  var todos

  @State
  var text = ""

  var body: some View {
    HStack {
      TextField("Enter your todo", text: $text)

#if os(iOS) || os(macOS)
        .textFieldStyle(.roundedBorder)
#endif

      Button("Add", action: addTodo)
        .disabled(text.isEmpty)
    }
    .padding(.vertical)
  }

  func addTodo() {
    let todo = Todo(id: UUID(), text: text, isCompleted: false)
    todos.append(todo)
    text = ""
  }
}

struct TodoItem: View {
  @WatchState(TodosAtom())
  var allTodos

  @State
  var text: String

  @State
  var isCompleted: Bool

  let todo: Todo

  init(todo: Todo) {
    self.todo = todo
    self._text = State(initialValue: todo.text)
    self._isCompleted = State(initialValue: todo.isCompleted)
  }

  var index: Int {
    allTodos.firstIndex { $0.id == todo.id }!
  }

  var body: some View {
    Toggle(isOn: $isCompleted) {
      TextField("", text: $text) {
        allTodos[index].text = text
      }
      .textFieldStyle(.plain)

#if os(iOS) || os(macOS)
      .textFieldStyle(.roundedBorder)
#endif
    }
    .padding(.vertical, 4)
    .onChange(of: isCompleted) { isCompleted in
      allTodos[index].isCompleted = isCompleted
    }
  }
}


struct AtomCaseStudiesView: View {
  @Watch(CounterAtom())
  var count

  @Watch(FilteredTodosAtom())
  var filteredTodos

  @ViewContext
  var context


  var body: some View {
    List {
      VStack {
        HStack {
          Text(count.description)
          Spacer()
          CountStepper()
        }
        .hideListRowSeperator()

        Section {
          TodoStats()
          TodoCreator()
        }
        .hideListRowSeperator()

        Section {
          TodoFilters()

          ForEach(filteredTodos, id: \.id) { todo in
            TodoItem(todo: todo)
          }
          .onDelete { indexSet in
            let filtered = filteredTodos
            context.modify(TodosAtom()) { todos in
              let indices = indexSet.compactMap { index in
                todos.firstIndex(of: filtered[index])
              }
              todos.remove(atOffsets: IndexSet(indices))
            }
          }
          .hideListRowSeperator()
        }
        .hideListRowSeperator()
        Spacer()
      }
      .padding()
    }
    .listStyle(.plain)
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
      AtomRoot {
        _NavigationView {
          AtomCaseStudiesView()
        }
      }
    }
}
