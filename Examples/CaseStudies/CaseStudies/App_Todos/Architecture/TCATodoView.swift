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

private struct TCATodoReducer: Reducer {

  struct State: Equatable {
    var todos: IdentifiedArrayOf<Todo> = .mock
    @BindingState var filter: Filter = .all
    var filteredTodos: IdentifiedArrayOf<Todo> {
      switch filter {
        case .all:
          return todos
        case .completed:
          return todos.filter(\.isCompleted)
        case .uncompleted:
          return todos.filter { !$0.isCompleted }
      }
    }

    var stats: Stats {
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

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case remove(atOffsets: IndexSet)
    case move(fromOffsets: IndexSet, toOffset: Int)
    case createTodo(todo: Todo)
    case setText(todoID: UUID, text: String)
    case setIsCompleted(todoID: UUID, isCompleted: Bool)
  }

  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
        case .setText(let id,let txt):
          state.todos[id: id]?.text = txt
        case .setIsCompleted(let id, let isCompleted):
          state.todos[id: id]?.isCompleted = isCompleted
        case .createTodo(let todo):
          state.todos.updateOrAppend(todo)
        case .remove(let atOffsets):
          state.todos.remove(atOffsets: atOffsets)
        case .move(let fromOffsets,let toOffset):
          state.todos.move(fromOffsets: fromOffsets, toOffset: toOffset)
        default:
          break
      }
      return .none
    }
  }
}

private struct TCATodoMiddleware: Middleware {
  typealias State = TCATodoReducer.State

  typealias Action = TCATodoReducer.Action

  var body: some MiddlewareOf<Self> {
    AsyncIOMiddleware { state, action, source in
      AsyncIO { handler in
        switch action {
          default:
            break
        }
      }
    }
  }
}

private struct TodoStats: View {
  
  @ObservedObject
  private var viewStore: ViewStoreOf<TCATodoReducer>
  
  init(viewStore: ViewStoreOf<TCATodoReducer>) {
    self.viewStore = viewStore
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      stat("Total", "\(viewStore.stats.total)")
      stat("Completed", "\(viewStore.stats.totalCompleted)")
      stat("Uncompleted", "\(viewStore.stats.totalUncompleted)")
      stat("Percent Completed", "\(Int(viewStore.stats.percentCompleted * 100))%")
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

  @ObservedObject
  private var viewStore: ViewStoreOf<TCATodoReducer>
  
  init(viewStore: ViewStoreOf<TCATodoReducer>) {
    self.viewStore = viewStore
  }

  var body: some View {
    Picker("Filter", selection: viewStore.$filter) {
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

  @ObservedObject
  private var viewStore: ViewStoreOf<TCATodoReducer>

  init(viewStore: ViewStoreOf<TCATodoReducer>) {
    self.viewStore = viewStore
  }

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
          viewStore.send(.createTodo(todo: Todo(id: UUID(), text: text, isCompleted: false)))
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

  @ObservedObject
  private var viewStore: ViewStoreOf<TCATodoReducer>

  fileprivate let todo: Todo
  
  @State private var isCompleted: Bool
  @State private var text: String

  fileprivate init(viewStore: ViewStoreOf<TCATodoReducer>, todo: Todo) {
    self.viewStore = viewStore
    self.todo = todo
    self._isCompleted = State(initialValue: todo.isCompleted)
    self._text = State(initialValue: todo.text)
  }

  var body: some View {
    Toggle(isOn: $isCompleted) {
      TextField("", text: $text) {

      }
      .textFieldStyle(.plain)
#if os(iOS) || os(macOS)
      .textFieldStyle(.roundedBorder)
#endif
    }
    .padding(.vertical, 4)
    .onChange(of: isCompleted) { newValue in
      viewStore.send(.setIsCompleted(todoID: todo.id, isCompleted: newValue))
    }
    .onChange(of: text) { newValue in
      viewStore.send(.setText(todoID: todo.id, text: newValue))
    }
  }
}

// MARK: View
struct TCATodoView: View {

  private let store: StoreOf<TCATodoReducer>

  @ObservedObject
  private var viewStore: ViewStoreOf<TCATodoReducer>

  init() {
    self.init(store: nil)
  }

  private init(store: StoreOf<TCATodoReducer>?) {
    let unwrapStore = store ?? Store(
      initialState: TCATodoReducer.State()
    ) {
      TCATodoReducer()
    }
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore)
  }

  var body: some View {
    List {
      Section(header: Text("Information")) {
        TodoStats(viewStore: viewStore)
        TodoCreator(viewStore: viewStore)
      }
      Section(header: Text("Filters")) {
        TodoFilters(viewStore: viewStore)
      }
      ForEach(viewStore.filteredTodos, id: \.id) { todo in
        TodoItem(viewStore: viewStore, todo: todo)
      }
      .onDelete { indexSet in
        viewStore.send(.remove(atOffsets: indexSet))
      }
      .onMove { fromOffsets, toOffset in
        viewStore.send(.move(fromOffsets: fromOffsets, toOffset: toOffset))
      }
    }
    .listStyle(.sidebar)
    .toolbar {
      if viewStore.filter == .all {
#if os(iOS)
        EditButton()
#endif
      }
    }
    .navigationTitle("TCA-Todos")
#if os(iOS)
    .navigationBarTitleDisplayMode(.inline)
#endif
  }
}

#Preview {
  TCATodoView()
}
