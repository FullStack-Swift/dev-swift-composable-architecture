import SwiftUI

public extension DependencyValues {
  var urlString: String {
    "https://todolistappproj.herokuapp.com/todos"
  }
}


struct MainReducer: ReducerProtocol {

  // MARK: State
  struct State: Equatable {
    var counterState = CounterReducer.State()
    @BindingState var title: String = ""
    var todos: IdentifiedArrayOf<TodoModel> = []
    var isLoading: Bool = false
  }

  // MARK: Action
  enum Action: BindableAction, Equatable {
    /// subview Action
    case counterAction(CounterReducer.Action)
    /// view Action
    case viewOnAppear
    case viewOnDisappear
    case none
    case binding(_ action: BindingAction<MainReducer.State>)
    case toggleTodo(TodoModel)
    case logout
    case changeRootScreen(RootReducer.RootScreen)
    case viewCreateTodo
    /// network Action
    case getTodo
    case responseTodo(Data)
    case createOrUpdateTodo(TodoModel)
    case responseCreateOrUpdateTodo(Data)
    case updateTodo(TodoModel)
    case responseUpdateTodo(Data)
    case deleteTodo(TodoModel)
    case responseDeleteTodo(Data)
  }

  // MARK: Dependency
  @Dependency(\.uuid) var uuid
  @Dependency(\.urlString) var urlString

  // MARK: Reducer
  var body: some ReducerProtocolOf<Self> {
    Reduce { state, action in
      switch action {
          // MARK: - SubView Action
        case .counterAction(let counterAction):
          print(counterAction)
          // MARK: - View Action
        case .viewOnAppear:
          return EffectTask(value: .getTodo)
        case .viewOnDisappear:
          break
        case .binding(let bindingAction):
          print(bindingAction)
        case .toggleTodo(let todo):
          //        state.todos[id: todo.id]?.isCompleted.toggle()
          if var todo = state.todos.filter({$0.id == todo.id}).first {
            todo.isCompleted.toggle()
            return EffectTask(value: .updateTodo(todo))
          }
        case .logout:
          return EffectTask(value: .changeRootScreen(.auth))
        case .viewCreateTodo:
          if state.title.isEmpty {
            return .none
          }
          let title = state.title
          state.title = ""
          let id = uuid()
          let todo = TodoModel(id: id, title: title, isCompleted: false)
          return EffectTask(value: .createOrUpdateTodo(todo))

          // MARK: - Networking
          /// GET TODO
        case .getTodo:
          if state.isLoading {
            return .none
          }
          state.isLoading = true
          state.todos.removeAll()
          let request = MRequest {
            RUrl(urlString: urlString)
            RMethod(.get)
          }
          return request
            .compactMap({$0.data})
            .map(MainReducer.Action.responseTodo)
            .eraseToEffect()
        case .responseTodo(let json):
          if let items = json.toModel([TodoModel].self) {
            for item in items {
              state.todos.updateOrAppend(item)
            }
          }
          /// CREATE OR UPDATE TODO
        case .createOrUpdateTodo(let todo):
          let request = MRequest {
            RUrl(urlString: urlString)
            REncoding(JSONEncoding.default)
            RMethod(.post)
            Rbody(todo.toData())
          }
          return request
            .compactMap{$0.data}
            .map(MainReducer.Action.responseCreateOrUpdateTodo)
            .eraseToEffect()
        case .responseCreateOrUpdateTodo(let json):
          if let item = json.toModel(TodoModel.self) {
            state.todos.updateOrAppend(item)
          }
          /// UPDATE TODO
        case .updateTodo(let todo):
          let request = MRequest {
            RUrl(urlString: urlString)
              .withPath(todo.id.toString())
            RMethod(.post)
            Rbody(todo.toData())
          }
          return request
            .compactMap{$0.data}
            .map(MainReducer.Action.responseUpdateTodo)
            .eraseToEffect()
        case .responseUpdateTodo(let json):
          if let item = json.toModel(TodoModel.self) {
            state.todos.updateOrAppend(item)
          }
          /// DELETE TODO
        case .deleteTodo(let todo):
          let request = MRequest {
            RUrl(urlString: urlString)
              .withPath(todo.id.toString())
            RMethod(.delete)
          }
          return request
            .compactMap{$0.data}
            .map(MainReducer.Action.responseDeleteTodo)
            .eraseToEffect()
        case .responseDeleteTodo(let json):
          if let item = json.toModel(TodoModel.self) {
            state.todos.remove(item)
          }
        default:
          break
      }
      return .none
    }
    ._printChanges()
  }
}

struct MainView: View {

  private let store: StoreOf<MainReducer>

  @ObservedObject
  private var viewStore: ViewStoreOf<MainReducer>

  init(store: StoreOf<MainReducer>? = nil) {
    let unwrapStore = store ?? Store(
      initialState: MainReducer.State(),
      reducer: MainReducer()
    )
    self.store = unwrapStore
    self.viewStore = ViewStore(unwrapStore)
  }

  var body: some View {
    ZStack {
#if os(macOS)
      content
        .toolbar {
          ToolbarItem(placement: .status) {
            HStack {
              CounterView(
                store: store
                  .scope(
                    state: \.counterState,
                    action: Main.Action.counterAction
                  )
              )
              Spacer()
              Button(action: {
                viewStore.send(.logout)
              }, label: {
                Text("Logout")
                  .foregroundColor(Color.blue)
              })
            }
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
#endif
#if os(iOS)
      NavigationView {
        content
          .navigationTitle("Todos")
          .navigationBarItems(leading: leadingBarItems, trailing: trailingBarItems)
      }
      .navigationViewStyle(.stack)
#endif
    }
    .onAppear {
      viewStore.send(.viewOnAppear)
    }
    .onDisappear {
      viewStore.send(.viewOnDisappear)
    }
  }
}


extension MainView {
  /// create content view in screen
  private var content: some View {
    List {
      Section {
        ZStack {
          HStack {
            Spacer()
            if viewStore.isLoading {
              ProgressView()
            } else {
              Text("Reload")
                .bold()
                .onTapGesture {
                  viewStore.send(.getTodo)
                }
            }
            Spacer()
          }
          .frame(height: 60)
        }
      }
      HStack {
        TextField("title", text: viewStore.binding(\.$title))
        Button(action: {
          viewStore.send(.viewCreateTodo)
        }, label: {
          Text("Create")
            .bold()
            .foregroundColor(viewStore.title.isEmpty ? Color.gray : Color.green)
        })
        .disabled(viewStore.title.isEmpty)
      }

      ForEach(viewStore.todos) { todo in
        HStack {
          HStack {
            Image(systemName: todo.isCompleted ? "checkmark.square" : "square")
              .frame(width: 40, height: 40, alignment: .center)
            Text(todo.title)
              .underline(todo.isCompleted, color: Color.black)
            Spacer()
          }
          .contentShape(Rectangle())
          .onTapGesture {
            viewStore.send(.toggleTodo(todo))
          }
          Button(action: {
            viewStore.send(.deleteTodo(todo))
          }, label: {
            Text("Delete")
              .foregroundColor(Color.gray)
          })
        }
      }
      .padding(.all, 0)
    }
    .padding(.all, 0)
  }

  private var leadingBarItems: some View {
    CounterView(
      store: store
        .scope(
          state: \.counterState,
          action: MainReducer.Action.counterAction
        )
    )
  }

  private var trailingBarItems: some View {
    Button(action: {
      viewStore.send(.logout)
    }, label: {
      Text("Logout")
        .foregroundColor(Color.blue)
    })
  }

  func shayHelo() async -> String {
    print(Date())
    sleep(3)
    let reulst = "heello"
    return reulst
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}
