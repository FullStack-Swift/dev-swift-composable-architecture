import SwiftUI
import ComposableArchitecture
import Json

// MARK: Model

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

// MARK: Mock Data
extension IdentifiedArray where ID == Todo.ID, Element == Todo {
  static let mock: Self = [
    Todo(
      id: UUID(),
      text: "A",
      isCompleted: false
    ),
    Todo(
      id: UUID(),
      text: "B",
      isCompleted: true
    ),
    Todo(
      id: UUID(),
      text: "C",
      isCompleted: false
    ),
    Todo(
      id: UUID(),
      text: "D",
      isCompleted: true
    ),
  ]
}


// MARK: Recoil Atom

@MainActor
private let _todosAtom = MStateAtom<IdentifiedArray<Todo.ID,Todo>>(id: sourceId()) { context in
  return .mock
}

@MainActor
private let _filterAtom = MStateAtom<Filter>(id: sourceId()) { context in
  return .all
}

@MainActor
private let _filteredTodosAtom = MValueAtom<IdentifiedArrayOf<Todo>>(id: sourceId()) { context in
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

@MainActor
private let _statsAtom = MValueAtom<Stats>(id: sourceId()) { context in
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

@MainActor
private let totalTodos = selectorValue { context in
  context.watch(_todosAtom).count
}

// MARK: View

private struct TodoStats: View {
  
  var body: some View {
    HookScope {
      let stats = useRecoilValue(_statsAtom)
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
  
  var body: some View {
    HookScope {
      let filter = useRecoilState(_filterAtom)
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
  
  var body: some View {
    HookScope {
      let text = useState("")
      let todos = useRecoilState(_todosAtom)
      HStack {
        TextField("Enter your todo", text: text)
#if os(iOS) || os(macOS)
          .textFieldStyle(.plain)
#endif
        Button {
          todos.wrappedValue.append(Todo(id: UUID(), text: text.wrappedValue, isCompleted: false))
          text.wrappedValue = ""
        } label: {
          Text("Add")
            .bold()
            .foregroundColor(text.wrappedValue.isEmpty ? .gray : .green)
        }
        .disabled(text.wrappedValue.isEmpty)
      }
      .padding(.vertical)
    }
  }
}

private struct TodoItem: View {
  
  fileprivate let todoID: UUID
  
  fileprivate init(todoID: UUID) {
    self.todoID = todoID
  }
  
  var body: some View {
    HookScope {
      let todos = useRecoilState(_todosAtom)
      if let todo = todos.first(where: {$0.wrappedValue.id == self.todoID}) {
        Toggle(isOn: todo.map(\.isCompleted)) {
          TextField("", text: todo.map(\.text)) {
          }
          .textFieldStyle(.plain)
#if os(iOS) || os(macOS)
          .textFieldStyle(.roundedBorder)
#endif
        }
        .padding(.vertical, 4)
      }
    }
  }
}

struct RecoilTodoView: View {
  
  var body: some View {
    HookScope {
      let filteredTodos = useRecoilValue(_filteredTodosAtom)
      let todos = useRecoilState(_todosAtom)
      List {
        Section(header: Text("Information")) {
          TodoStats()
          TodoCreator()
        }
        Section(header: Text("Filters")) {
          TodoFilters()
        }
        ForEach(filteredTodos, id: \.id) { todo in
          TodoItem(todoID: todo.id)
        }
        .onDelete { atOffsets in
          todos.wrappedValue.remove(atOffsets: atOffsets)
        }
        .onMove { fromOffsets, toOffset in
          todos.wrappedValue.move(fromOffsets: fromOffsets, toOffset: toOffset)
        }
      }
      .listStyle(.sidebar)
      .toolbar {
        if useRecoilState(_filterAtom).wrappedValue == .all {
          EditButton()
        }
      }
      .navigationTitle("Recoil-Todos-" + useRecoilValue(totalTodos).description)
      .navigationBarItems(leading: leading, trailing: trailing)
      .navigationBarTitleDisplayMode(.inline)
    }
  }
  
  private var leading: some View {
    EmptyView()
  }
  
  private var trailing: some View {
    NavigationLink(destination: OnlineRecoilTodoView()) {
      Text("online")
    }
  }
}

struct RecoilTodoView_Previews: PreviewProvider {
  static var previews: some View {
    AtomRoot {
      _NavigationView {
        RecoilTodoView()
      }
    }
  }
}
