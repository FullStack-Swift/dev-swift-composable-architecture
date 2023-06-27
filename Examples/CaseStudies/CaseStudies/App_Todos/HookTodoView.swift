import SwiftUI
import ComposableArchitecture

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

private typealias TodoContext = HookContext<Binding<IdentifiedArrayOf<Todo>>>

private struct TodoStats: View {
  var body: some View {
    HookScope {
      let todos = useContext(TodoContext.self).wrappedValue
      let total = todos.count
      let totalCompleted = todos.filter(\.isCompleted).count
      let totalUncompleted = todos.filter { !$0.isCompleted }.count
      let percentCompleted = total <= 0 ? 0 : (Double(totalCompleted) / Double(total))
      let stats = Stats(
        total: total,
        totalCompleted: totalCompleted,
        totalUncompleted: totalUncompleted,
        percentCompleted: percentCompleted
      )
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
  
  let filter: Binding<Filter>
  
  var body: some View {
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

private struct TodoCreator: View {
  
  let todos: Binding<IdentifiedArrayOf<Todo>>
  
  var body: some View {
    HookScope {
      let text = useState("")
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
      let todos = useContext(TodoContext.self)
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

struct HookTodoView: View {
  
  var body: some View {
    HookScope {

      let todos = useState {
        IdentifiedArrayOf<Todo>.mock
      }
      
      let filter = useState<Filter> {
        return Filter.all
      }
      
      let flag = useState(false)
      
      let filteredTodos = useMemo(.preserved(by: flag.wrappedValue)) { () -> IdentifiedArrayOf<Todo> in
        let filter = filter.wrappedValue
        let todos = todos.wrappedValue
        switch filter {
          case .all:
            return todos
          case .completed:
            return todos.filter(\.isCompleted)
          case .uncompleted:
            return todos.filter { !$0.isCompleted }
        }
      }
      
      TodoContext.Provider(value: todos) {
        List {
          Section(header: Text("Information")) {
            TodoStats()
            TodoCreator(todos: todos)
              .onChange(of: todos.wrappedValue) { newValue in
                flag.wrappedValue.toggle()
              }
          }
          Section(header: Text("Filters")) {
            TodoFilters(filter: filter)
              .onChange(of: filter.wrappedValue) { newValue in
                flag.wrappedValue.toggle()
              }
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
          EditButton()
        }
        .navigationTitle("Hook-Todos")
        .navigationBarTitleDisplayMode(.inline)
      }
    }
  }
}

struct HookTodoView_Previews: PreviewProvider {
  static var previews: some View {
    _NavigationView {
      HookTodoView()
    }
  }
}
