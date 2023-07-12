import SwiftUI
import Combine
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

private class TodoProvider: StateProvider<IdentifiedArrayOf<Todo>> {
  
  override init(_ initialState: IdentifiedArrayOf<Todo>) {
    super.init(initialState)
  }
  
  convenience init() {
    self.init(.mock)
  }
}

private class FilterProvier: StateProvider<Filter> {
  
  override init(_ initialState: Filter) {
    super.init(initialState)
  }
  
  convenience init() {
    self.init(.all)
  }
}

private class FilterTodoProvider: ValueProvider<IdentifiedArrayOf<Todo>> {
  
  override var result: IdentifiedArrayOf<Todo> {
    let filter = context.watch(filterProvier)
    let todos = context.watch(todoProvider)
    switch filter {
      case .all:
        return todos
      case .completed:
        return todos.filter(\.isCompleted)
      case .uncompleted:
        return todos.filter { !$0.isCompleted }
    }
  }
  
  override init(_ initialState: IdentifiedArrayOf<Todo>) {
    super.init(initialState)
  }
  
  convenience override init() {
    self.init(.mock)
  }
}

private class StatsProvider: ValueProvider<Stats> {
  
  override var result: Stats {
    let todos = context.watch(todoProvider)
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


private let todoProvider = TodoProvider()
private let filterProvier = FilterProvier()
private let filterTodoProvider = FilterTodoProvider()

// MARK: TodoStats
private struct TodoStats: ConsumerView {
  func build(context: Context, ref: ViewRef) -> some View {
    let todos = ref.watch(todoProvider)
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
  
  private func stat(_ title: String, _ value: String) -> some View {
    HStack {
      Text(title) + Text(":")
      Spacer()
      Text(value)
    }
  }
}

// MARK: TodoFilters
private struct TodoFilters: ConsumerView {
  
  func build(context: Context, ref: ViewRef) -> some View {
    let filter = ref.binding(filterProvier)
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

// MARK: TodoCreator
private struct TodoCreator: ConsumerView {
  
  @State private var text: String = ""
  
  func build(context: Context, ref: ViewRef) -> some View {
    let todos = ref.binding(todoProvider)
    HStack {
      TextField("Enter your todo", text: $text)
#if os(iOS) || os(macOS)
        .textFieldStyle(.plain)
#endif
      Button {
        todos.wrappedValue.append(Todo(id: UUID(), text: text, isCompleted: false))
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

// MARK: TodoItem
private struct TodoItem: ConsumerView {
  
  fileprivate let todoID: UUID
  
  fileprivate init(todoID: UUID) {
    self.todoID = todoID
  }
  
  func build(context: Context, ref: ViewRef) -> some View {
    let todos = ref.binding(todoProvider)
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

// MARK: RiverpodTodoView
struct RiverpodTodoView: ConsumerView {
  
  func build(context: Context, ref: ViewRef) -> some View {
    let filterTodoProvider = FilterTodoProvider()
    List {
      Section(header: Text("Information")) {
        TodoStats()
        TodoCreator()
      }
      Section(header: Text("Filters")) {
        TodoFilters()
      }
      ForEach(filterTodoProvider.value, id: \.id) { todo in
        TodoItem(todoID: todo.id)
      }
      .onDelete { atOffsets in
        todoProvider.value.remove(atOffsets: atOffsets)
      }
      .onMove { fromOffsets, toOffset in
        todoProvider.value.move(fromOffsets: fromOffsets, toOffset: toOffset)
      }
    }
    .listStyle(.sidebar)
    .toolbar {
      if filterProvier.value == .all {
        EditButton()
      }
    }
    .navigationTitle("Riverpod-Todos")
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct RiverpodTodoView_Previews: PreviewProvider {
  static var previews: some View {
    _NavigationView {
      RiverpodTodoView()
    }
  }
}

struct Post: Codable {
  let id: Int
  let title: String
  let body: String
}

class PostStreamProvider: StreamProvider<[Post]> {
  
  init() {
    super.init {
      let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
      let decoder = JSONDecoder()
      let (data, _) = try await URLSession.shared.data(from: url)
      return try decoder.decode([Post].self, from: data)
    }
  }
}

class PostFutureProvider: FutureProvider<AnyPublisher<[Post], any Error>> {
  
  init() {
    super.init {
      let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
      let decoder = JSONDecoder()
      return URLSession.shared.dataTaskPublisher(for: url)
        .tryMap({ try decoder.decode([Post].self, from: $0.data)})
        .eraseToAnyPublisher()
    }
  }
}



struct APIRequestPage: ConsumerView {
 
//  let stream = PostStreamProvider()
//  let stream = PostFutureProvider()
  
  let stream = PostFutureProvider()

  func build(context: Context, ref: ViewRef) -> some View {
//    let phase = ref.watch(stream)
    
//    let stream = PostStreamProvider()
    let state = StateProvider<AsyncPhase<[Post], Error>> { context in
      context.watch(stream)
    }
    let phase = state.value
    ScrollView {
      VStack {
        switch phase {
          case .suspending:
            ProgressView()
            
          case .success(let posts):
            postRows(posts)
            
          case .failure(let error):
            errorRow(error, retry: {
              stream.refresh()
            })
        }
      }
      .padding(.vertical, 16)
      .padding(.horizontal, 24)
    }
    .onAppear {
      stream.refresh()
    }
    .navigationTitle("API Request")
    .background(Color(.systemBackground).ignoresSafeArea())
  }
  
  func postRows(_ posts: [Post]) -> some View {
    ForEach(posts, id: \.id) { post in
      VStack(alignment: .leading) {
        Text(post.title).bold()
        Text(post.body).padding(.vertical, 16)
        Divider()
      }
      .frame(maxWidth: .infinity)
    }
  }
  
  func errorRow(_ error: Error, retry: @escaping () async -> Void) -> some View {
    VStack {
      Text("Error: \(error.localizedDescription)")
        .fixedSize(horizontal: false, vertical: true)
      
      Divider()
      
      Button("Refresh") {
        Task {
          await retry()
        }
      }
    }
  }
}
