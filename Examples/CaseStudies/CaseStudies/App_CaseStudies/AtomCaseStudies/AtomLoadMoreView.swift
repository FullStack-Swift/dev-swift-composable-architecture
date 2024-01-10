import SwiftUI

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

// MARK: Mock Data
extension IdentifiedArray where ID == Todo.ID, Element == Todo {
  static var mock: Self {
    [
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
}


private var testNoContent: Bool = true

@MainActor
fileprivate let loadMoreAtom = MObservableObjectAtom(id: sourceId()) { context in
  LoadMoreObservableAtom<Todo>(firstPage: 1) { page in
    try? await Task.sleep(seconds: 2)
    var todos = IdentifiedArrayOf<Todo>.mock.toArray()
    if testNoContent {
      todos = []
      testNoContent.toggle()
    }
//    var todos = IdentifiedArrayOf<Todo>().toArray()
    return PagedResponse(page: page, totalPages: 10, results: todos)
  }
}

struct AtomLoadMoreView: View {
  
  @WatchStateObject(loadMoreAtom)
  private var loadMore
  
  var body: some View {
    
    let todos = loadMore.loadPhase.value?.results ?? []
    let status = loadMore.loadPhase
    
    ZStack {
      Color.almostClear
      switch status {
        case .pending:
          ProgressView()
            .frame(maxWidth: .infinity, idealHeight: 40)
        case .failure:
          Text("failure")
            .onTap {
              loadFirst()
            }
        case .success, .running:
          if todos.isEmpty {
            Text("No Content to show.")
              .onTap {
                loadFirst()
              }
          } else {
            List {
              ForEach(todos, id: \.id) { todo in
                Text(todo.text)
                Text(todo.id.description)
              }
              //            if loadMore.hasNextPage {
              if loadMore.loadPhase.value?.hasNextPage == true {
                ProgressView()
                  .frame(maxWidth: .infinity, idealHeight: 40)
                  .id(UUID())
                  .task {
                    loadnext()
                  }
              }
            }
            .navigationBarItems(leading: EmptyView(), trailing: refreshView)
            .navigationTitle(
              loadMore.isRefresh ? "is Refreshing" : "Todos-" + todos.count.description + " isLoading: " + (loadMore.isLoading).description
            )
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.grouped)
            .refreshable {
              refresh()
            }

          }
      }
    }
    .onFirstAppear {
      refresh()
    }
  }
  
  private var refreshView: some View {
    If(loadMore.isRefresh) {
      ProgressView()
    }
  }
  
  private func refresh() {
    Task { @MainActor in
      try await loadMore.refresh()
    }
  }
  
  private func loadFirst() {
    Task { @MainActor in
      try await loadMore.loadFirst()
    }
  }
  
  private func loadnext() {
    Task { @MainActor in
      try await loadMore.loadNext()
    }
  }
}

#Preview {
  AtomLoadMoreView()
}
