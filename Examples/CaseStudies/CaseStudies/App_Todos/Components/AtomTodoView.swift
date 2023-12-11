import SwiftUI

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
  
  @Watch(StatsAtom())
  private var stats
  
  var body: some View {
    HookScope {
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
  
  @WatchState(FilterAtom())
  private var filter
  
  var body: some View {
    HookScope {
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
}

private struct TodoCreator: View {
  
  @ViewContext
  private var context
  
  @WatchState(TodosAtom())
  private var todos
  
  var body: some View {
    HookScope {
      
      @HState
      var text = ""
      
      HStack {
        TextField("Enter your todo", text: $text)
#if os(iOS) || os(macOS)
          .textFieldStyle(.plain)
#endif
        Button {
          todos.append(Todo(id: UUID(), text: text, isCompleted: false))
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
  
  @WatchState(TodosAtom())
  private var todos
  
  fileprivate let todoID: UUID
  
  fileprivate init(todoID: UUID) {
    self.todoID = todoID
  }
  
  var body: some View {
    HookScope {
      if let todo = $todos.first(where: {$0.id == self.todoID}) {
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
  
  @Watch(FilteredTodosAtom())
  private var filteredTodos
  
  @WatchState(TodosAtom())
  private var todos
  
  @Watch(FilterAtom())
  private var filter
  
  @Watch(TodosCount())
  private var todosCount
  
  var body: some View {
    HookScope {
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
          todos.remove(atOffsets: atOffsets)
        }
        .onMove { fromOffsets, toOffset in
          todos.move(fromOffsets: fromOffsets, toOffset: toOffset)
        }
      }
      .onFirstAppear {
        
      }
      .onLastDisappear {
        
      }
      .listStyle(.sidebar)
      .toolbar {
        if filter == .all {
#if os(iOS)
          EditButton()
#endif
        }
      }
      .navigationTitle("Atom-Todos-" + todosCount.description)
#if os(iOS)
      .navigationBarItems(leading: leading, trailing: trailing)
      .navigationBarTitleDisplayMode(.inline)
#endif
    }
  }
  
  private var leading: some View {
    EmptyView()
  }
  
  private var trailing: some View {
    NavigationLink(destination: OnlineAtomTodoView()) {
      Text("online")
    }
  }
}

#Preview {
  AtomTodoView()
}
