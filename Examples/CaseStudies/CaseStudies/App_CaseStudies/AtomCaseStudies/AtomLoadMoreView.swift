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

@MainActor
fileprivate let loadMoreAtom = MObservableObjectAtom(id: sourceId()) { context in
  LoadMoreObservableAtom<Todo>(firstPage: 1) { page in
    let request = MRequest {
      RUrl("http://127.0.0.1:8080")
        .withPath("todos")
        .withPath("paginate")
      RQueryItems(["page": page.description, "per": 10.description])
      RMethod(.get)
    }
    await Task.sleepOptional(seconds: 2)
    let data = try await request.data
    log.json(data)
    var response = data.toModel(Page<Todo>.self) ?? Page(items: [], metadata: .init(page: 0, per: 0, total: 0))
    return PagedResponse(page: page, totalPages: response.metadata.totalPages, results: response.items)
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
