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

private struct TodosAtom: StateAtom, Hashable, KeepAlive {
  func defaultValue(context: Context) -> IdentifiedArrayOf<Todo> {
    []
  }
}

private struct FilterAtom: StateAtom, Hashable {
  func defaultValue(context: Context) -> Filter {
    .all
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
  @Watch(StatsAtom())
  private var stats

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      stat("Total", "\(stats.total)")
      stat("Completed", "\(stats.totalCompleted)")
      stat("Uncompleted", "\(stats.totalUncompleted)")
      stat("Percent Completed", "\(Int(stats.percentCompleted * 100))%")
    }
    .padding(.vertical)
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
  @WatchState(FilterAtom())
  private var filter

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

private struct TodoCreator: View {
  @WatchState(TodosAtom())
  private var todos

  @State
  private var text = ""

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

  private func addTodo() {
    let todo = Todo(id: UUID(), text: text, isCompleted: false)
    todos.append(todo)
    text = ""
  }
}

private struct TodoItem: View {
  @WatchState(TodosAtom())
  fileprivate var allTodos

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

  private var index: Int {
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


struct AtomTodoView: View {

  @Watch(FilteredTodosAtom())
  private var filteredTodos

  @ViewContext
  private var context


  var body: some View {
    ScrollView {
      VStack {
        Section {
          TodoStats()
          TodoCreator()
        }
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
        }
      }
      .padding()
    }
    .navigationTitle("Todos")
    .navigationBarItems(leading: leading, trailing: trailing)
  }
}

extension AtomTodoView {
  @ViewBuilder
  private var leading: some View {
    EmptyView()
  }

  @ViewBuilder
  private var trailing: some View {
    EmptyView()
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
