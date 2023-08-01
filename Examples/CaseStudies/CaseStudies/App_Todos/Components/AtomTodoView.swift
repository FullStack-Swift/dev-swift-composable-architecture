import SwiftUI
import ComposableArchitecture
import SwiftUIViewModifier

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


// MARK: Atom
private struct TodosAtom: StateAtom, Hashable, KeepAlive {
  func defaultValue(context: Context) -> IdentifiedArrayOf<Todo> {
    .mock
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

private struct TodosCount: ValueAtom, Hashable {
  
  func value(context: Context) -> Int {
    context.watch(TodosAtom()).count
  }
  
}

// MARK: View
private struct TodoStats: View {
  
  @ViewContext
  private var context
  
  var body: some View {
    HookScope {
      let stats = context.useRecoilValue(StatsAtom())
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
      let filter = context.useRecoilState(FilterAtom())
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
  
  var body: some View {
    HookScope {
      let text = useState("")
      let todos = context.useRecoilState(TodosAtom())
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
  
  @ViewContext
  private var context
  
  fileprivate let todoID: UUID
  
  fileprivate init(todoID: UUID) {
    self.todoID = todoID
  }
  
  var body: some View {
    HookScope {
      let todos = context.useRecoilState(TodosAtom())
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


struct AtomTodoView: View {
  
  @ViewContext
  private var context
  
  var body: some View {
    HookScope {
      let filteredTodos = context.useRecoilValue(FilteredTodosAtom())
      let todos = context.useRecoilState(TodosAtom())
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
      .onFirstAppear {
        
      }
      .onLastDisappear {
        
      }
      .listStyle(.sidebar)
      .toolbar {
        if context.useRecoilState(FilterAtom()).wrappedValue == .all {
          EditButton()
        }
      }
      .navigationTitle("Atom-Todos-" + context.watch(TodosCount()).description)
      .navigationBarItems(leading: leading, trailing: trailing)
      .navigationBarTitleDisplayMode(.inline)
    }
  }
  
  private var leading: some View {
    EmptyView()
  }
  
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
