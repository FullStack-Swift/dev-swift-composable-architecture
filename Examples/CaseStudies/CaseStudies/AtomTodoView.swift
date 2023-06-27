import SwiftUI
import ComposableArchitecture

private struct Todo: Hashable, Identifiable {
  var id: UUID
  var text: String
  var isCompleted: Bool
}

private enum Filter: CaseIterable, Hashable {
  case all
  case completed
  case uncompleted
}

private struct Stats: Equatable {
  let total: Int
  let totalCompleted: Int
  let totalUncompleted: Int
  let percentCompleted: Double
}

private let _todosAtom = MStateAtom<IdentifiedArray<Todo.ID,Todo>>(id: "_todosatom") { context in
  return IdentifiedArray(uniqueElements: [
    Todo(id: UUID(), text: "A", isCompleted: true),
    Todo(id: UUID(), text: "B", isCompleted: false),
    Todo(id: UUID(), text: "C", isCompleted: true),
    Todo(id: UUID(), text: "D", isCompleted: false)
  ])
}

private struct TodosAtom: StateAtom, Hashable, KeepAlive {
  func defaultValue(context: Context) -> IdentifiedArrayOf<Todo> {
    [
      Todo(id: UUID(), text: "A", isCompleted: true),
      Todo(id: UUID(), text: "B", isCompleted: false),
      Todo(id: UUID(), text: "C", isCompleted: true),
      Todo(id: UUID(), text: "D", isCompleted: false)
    ]
  }
}

private let _filterAtom = MStateAtom<Filter>(id: "_filterAtom") { context in
  return .all
}

private struct FilterAtom: StateAtom, Hashable {
  func defaultValue(context: Context) -> Filter {
    .all
  }
}

@MainActor
private let _filteredTodosAtom = MValueAtom<IdentifiedArray<Todo.ID,Todo>>(id: "_filteredTodosAtom") { context in
  let filter = context.watch(_filterAtom)
  let todos = context.watch(_todosAtom)
  switch filter {
    case .all:
      return todos
    case .completed:
      return todos.filter(\.isCompleted)
    case .uncompleted:
      return todos.filter { !$0.isCompleted }
  }
}
private struct FilteredTodosAtom: ValueAtom, Hashable {
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

@MainActor
private let _statsAtom = MValueAtom<Stats>(id: "_statsAtom") { context in
  let todos = context.watch(_todosAtom)
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

private struct StatsAtom: ValueAtom, Hashable {
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

private struct TodoStats: View {

  @ViewContext
  private var context

  var body: some View {
    HookScope {
//      let stats = context.useRecoilValue(StatsAtom())
      let stats = context.useRecoilValue(_statsAtom)
      VStack(alignment: .leading, spacing: 4) {
        stat("Total", "\(stats.total)")
        stat("Completed", "\(stats.totalCompleted)")
        stat("Uncompleted", "\(stats.totalUncompleted)")
        stat("Percent Completed", "\(Int(stats.percentCompleted * 100))%")
      }
      .padding(.vertical)
    }
  }

  private func stat(_ title: String, _ value: String) -> some View {
    HStack {
      Text(title) + Text(":")
      Spacer()
      Text(value)
    }
  }
}

private struct TodoFilters: View {

  @ViewContext
  private var context

  var body: some View {
    HookScope {
//      let filter = context.useRecoilState(FilterAtom())
      let filter = context.useRecoilState(_filterAtom)
      Picker("Filter", selection: filter) {
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
}

private struct TodoCreator: View {

  @ViewContext
  private var context

  @State
  private var text = ""

  var body: some View {
    HookScope {
      let todo = Todo(id: UUID(), text: text, isCompleted: false)
//      let todos = context.useRecoilState(TodosAtom())
      let todos = context.useRecoilState(_todosAtom)
      HStack {
        TextField("Enter your todo", text: $text)
#if os(iOS) || os(macOS)
          .textFieldStyle(.plain)
#endif
        Button {
          todos.wrappedValue.append(todo)
          text = ""
        } label: {
          Text("Add")
            .bold()
            .foregroundColor(text.isEmpty ? .gray : .green)
        }
        .disabled(text.isEmpty)
      }
      .padding(.vertical)
    }
  }
}

private struct TodoItem: View {

  @ViewContext
  private var context

  @State
  private var text: String

  @State
  private var isCompleted: Bool

  fileprivate let todo: Todo

  fileprivate init(todo: Todo) {
    self.todo = todo
    self._text = State(initialValue: todo.text)
    self._isCompleted = State(initialValue: todo.isCompleted)
  }

  var body: some View {
    HookScope {
//      let todos = context.useRecoilState(TodosAtom())
      let todos = context.useRecoilState(_todosAtom)
      Toggle(isOn: $isCompleted) {
        TextField("", text: $text) {
          todos.wrappedValue[id: todo.id]?.text = text
        }
        .textFieldStyle(.plain)

#if os(iOS) || os(macOS)
        .textFieldStyle(.roundedBorder)
#endif
      }
      .padding(.vertical, 4)
      .onChange(of: isCompleted) { isCompleted in
        todos.wrappedValue[id: todo.id]?.isCompleted.toggle()
      }
    }
  }
}


struct AtomTodoView: View {

  @ViewContext
  private var context

  var body: some View {
    HookScope {
//      let filteredTodos = context.useRecoilValue(FilteredTodosAtom())
//      let todos = context.useRecoilState(TodosAtom())
      let filteredTodos = context.useRecoilValue(_filteredTodosAtom)
      let todos = context.useRecoilState(_todosAtom)
      List {
        Section {
          TodoStats()
          TodoCreator()
        }
        Section {
          TodoFilters()
        }
        ForEach(filteredTodos, id: \.id) { todo in
          TodoItem(todo: todo)
        }
        .onDelete { indexSet in
          todos.wrappedValue.remove(atOffsets: indexSet)
        }
        .onMove { from, to in
          todos.wrappedValue.move(fromOffsets: from, toOffset: to)
        }
      }
      .listStyle(.sidebar)
      .toolbar {
        EditButton()
      }
      .navigationTitle("Todos")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

struct AtomTodoView_Previews: PreviewProvider {
  static var previews: some View {
    AtomRoot {
      _NavigationView {
        AtomTodoView()
      }
    }
  }
}
