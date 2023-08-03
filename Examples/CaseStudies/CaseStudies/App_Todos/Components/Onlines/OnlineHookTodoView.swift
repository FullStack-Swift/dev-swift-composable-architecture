import SwiftUI
import ComposableArchitecture
import MCombineRequest
import Transform
import SwiftLogger

// MARK: Model

private struct Todo: Codable, Hashable, Identifiable {
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

// MARK: View

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
    HookScope {
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
      let todos = useContext(TodoContext.self)
      let text = useState("")
      let _onlCreateTodo = useParamCallBack { (param: String) async throws -> Data in
        let data = try await MRequest {
          RUrl(urlString: "http://127.0.0.1:8080")
            .withPath("todos")
          Rbody(Todo(id: UUID(), text: param, isCompleted: false).toData())
          RMethod(.post)
          REncoding(JSONEncoding.default)
        }
          .printCURLRequest()
          .data
        return data
      }
      HStack {
        TextField("Enter your todo", text: text)
#if os(iOS) || os(macOS)
          .textFieldStyle(.plain)
#endif
        Button {
          Task {
            let data = try await _onlCreateTodo(text.wrappedValue)
            text.wrappedValue = ""
            if let item = data.toModel(Todo.self) {
              todos.wrappedValue.updateOrAppend(item)
            }
          }
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
      let _onlUpdateTodo = useParamCallBack { (param: Todo) async throws -> Data in
        let data: Data = try await MRequest {
          RUrl(urlString: "http://127.0.0.1:8080")
            .withPath("todos")
            .withPath(param.id.uuidString)
          Rbody(param.toData())
          RMethod(.post)
          REncoding(JSONEncoding.default)
        }
          .printCURLRequest()
          .data
        return data
      }
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
        .onChange(of: todo.wrappedValue) { (value: Todo) in
          print(value)
          Task {
            let data = try await _onlUpdateTodo(value)
            if let item = data.toModel(Todo.self) {
              todos.wrappedValue.updateOrAppend(item)
            }
          }
        }
      }
    }
  }
}

struct OnlineHookTodoView: View {
  
  @ViewBuilder
  var body: some View {
    HookScope {
      
      let todos = useState(IdentifiedArrayOf<Todo>())
      
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
      
      let (phase, refresher) = useAsyncRefresh { () -> IdentifiedArrayOf<Todo> in
        let request = MRequest {
          RUrl(urlString: "http://127.0.0.1:8080")
            .withPath("todos")
          RMethod(.get)
        }
        let data = try await request.data
        let models = data.toModel(IdentifiedArrayOf<Todo>.self) ?? []
        return models
      }
      
      let _ = useLayoutEffect(.preserved(by: phase.status)) {
        switch phase {
          case .success(let items):
            todos.wrappedValue = items
            flag.wrappedValue.toggle()
          default:
            break
        }
        return nil
      }
      
      let _onlDeleteTodo = useParamCallBack { (param: UUID) async throws -> Data in
        let data: Data = try await MRequest {
          RUrl(urlString: "http://127.0.0.1:8080")
            .withPath("todos")
            .withPath(param.uuidString)
          RMethod(.delete)
        }
          .printCURLRequest()
          .data
        log.info(data.toJson())
        return data
      }
      
      TodoContext.Provider(value: todos) {
        List {
          Section(header: Text("Information")) {
            TodoStats()
            TodoCreator()
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
          switch phase {
            case .success:
              ForEach(filteredTodos, id: \.id) { todo in
                TodoItem(todoID: todo.id)
              }
              .onDelete { atOffsets in
                for index in atOffsets {
                  let todo = todos.wrappedValue[index]
                  Task {
                    _ = try await _onlDeleteTodo(todo.id)
                  }
                }
                todos.wrappedValue.remove(atOffsets: atOffsets)
              }
              .onMove { fromOffsets, toOffset in
                // Move only in local
                todos.wrappedValue.move(fromOffsets: fromOffsets, toOffset: toOffset)
              }
            case .failure(let error):
              Text(error.localizedDescription)
            default:
              ProgressView()
          }
        }
        .onAppear {
          refresher()
        }
        .refreshable(action: {
          refresher()
        })
        .listStyle(.sidebar)
        .toolbar {
          if filter.wrappedValue == .all {
#if os(iOS)
            EditButton()
#endif
          }
        }
        .navigationTitle("Hook-Todos-" + filteredTodos.count.description)
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
      }
    }
  }
}

#Preview {
  OnlineHookTodoView()
}
