import SwiftUI
import MCombineRequest

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

// MARK: Recoil Atom

@MainActor
private let todosAtom = selectorState { context -> IdentifiedArrayOf<Todo> in
  return []
}
  .onUpdated { oldValue, newValue, context in
    //    #mTodo("Todo something")
  }

@MainActor
private let filterAtom = selectorState { context -> Filter in
  return .all
}

@MainActor
private let filteredTodosAtom = selectorValue { context -> IdentifiedArrayOf<Todo> in
  let filter = context.watch(filterAtom)
  let todos = context.watch(todosAtom)
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
private let statsAtom = selectorValue { context -> Stats in
  var todos = context.watch(todosAtom)
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
private let totalTodos = selectorValue { context -> Int in
  context.watch(todosAtom).count
}

// MARK: View

private struct TodoStats: View {
  
  var body: some View {
    HookScope {
      let stats = useRecoilValue(statsAtom)
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
      let filter = useRecoilState(filterAtom)
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
      
      @HState
      var text = ""
      
      let request = useParamCallBack { (param: String) async throws -> Data in
        let data = try await MRequest {
          RUrl("http://127.0.0.1:8080")
            .withPath("todos")
          Rbody(Todo(id: UUID(), text: param, isCompleted: false).toData())
          RMethod(.post)
          REncoding(JSONEncoding.default)
        }
          .printCURLRequest()
          .data
        return data
      }
      let todos = useRecoilState(todosAtom)
      HStack {
        TextField("Enter your todo", text: $text)
#if os(iOS) || os(macOS)
          .textFieldStyle(.plain)
#endif
        Button {
          Task {
            let data = try await request(text)
            text = ""
            if let item = data.toModel(Todo.self) {
              todos.wrappedValue.updateOrAppend(item)
            }
          }
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
  
  fileprivate let todoID: UUID
  
  fileprivate init(todoID: UUID) {
    self.todoID = todoID
  }
  
  var body: some View {
    HookScope {
      let request = useParamCallBack { (param: Todo) async throws -> Data in
        let data: Data = try await MRequest {
          RUrl("http://127.0.0.1:8080")
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
      let todos = useRecoilState(todosAtom)
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
            let data = try await request(value)
            if let item = data.toModel(Todo.self) {
              todos.wrappedValue.updateOrAppend(item)
            }
          }
        }
      }
    }
  }
}

struct OnlineRecoilTodoView: View {
  
  var body: some View {
    HookScope {
      
      let todos = useRecoilState(todosAtom)
      let filteredTodos = useRecoilValue(filteredTodosAtom)
      
      let (phase, refresher) = useRecoilRefresher {
        selectorThrowingTask { context async throws -> IdentifiedArrayOf<Todo> in
          let request = MRequest {
            RUrl("http://127.0.0.1:8080")
              .withPath("todos")
            RMethod(.get)
          }
          let data = try await request.data
          log.json(data.toJson())
          let models = data.toModel(IdentifiedArrayOf<Todo>.self) ?? []
          context.set(models, for: todosAtom)
          return models
        }
      }
      let requestDelete = useParamCallBack { (param: UUID) async throws -> Data in
        let data: Data = try await MRequest {
          RUrl("http://127.0.0.1:8080")
            .withPath("todos")
            .withPath(param.uuidString)
          RMethod(.delete)
        }
          .printCURLRequest()
          .data
        log.json(data.toJson())
        return data
      }
      List {
        Section(header: Text("Information")) {
          TodoStats()
          TodoCreator()
        }
        Section(header: Text("Filters")) {
          TodoFilters()
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
                  _ = try await requestDelete(todo.id)
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
      .refreshable {
        refresher()
      }
      .listStyle(.sidebar)
      .toolbar {
        if useRecoilValue(filterAtom) == .all {
#if os(iOS)
          EditButton()
#endif
        }
      }
      .navigationTitle("Recoil-Todos-" + useRecoilValue(totalTodos).description)
#if os(iOS)
      .navigationBarTitleDisplayMode(.inline)
#endif
    }
  }
}

#Preview {
  OnlineRecoilTodoView()
}
