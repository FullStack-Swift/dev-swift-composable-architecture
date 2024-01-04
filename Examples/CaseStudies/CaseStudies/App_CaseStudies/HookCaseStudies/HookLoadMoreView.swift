import SwiftUI
import MRequest

struct HookLoadMoreView: View {
  
  let tabs = Array {
    TabItemData(image: "ic_tab",selectedImage: "ic_tab_selected",title: "useArray")
    TabItemData(image: "ic_tab", selectedImage: "ic_tab_selected", title: "useID")
    TabItemData(image: "ic_tab", selectedImage: "ic_tab_selected", title: "pageTodo")
  }
  
  var body: some View {
    HookScope {
      let selectedTab = useState(0)
      FTabBar(tabs: tabs, selectedIndex: selectedTab) { index in
        VStack {
          if index == 0 {
            PagedResponseTodo()
          } else if index == 1 {
            PagedIDResponseTodo()
          } else if index == 2 {
            HookPageTodo()
          } else {
            Color.white
          }
        }
      }
      .navigationBarItems(
        leading: viewBuilder {
          EmptyView()
        },
        trailing: viewBuilder {
          EmptyView()
        }
      )
    }
    .navigationBarTitle(Text("Hook LoadMore"), displayMode: .inline)
  }
}

fileprivate extension View {
  func viewLoadMore(loadmore: any LoadMoreProtocol) -> some View {
    LoadMoreView(loadmore: loadmore) {
      ProgressView()
    } moreContent: {
      Text("")
    } endContent: {
      Text("The End")
    }
  }
}


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

struct PagedResponseTodo: View {
  var body: some View {
    HookScope {
      let loadmore: LoadMoreAray<Todo> = useLoadMoreHookModel(firstPage: 1) { page in
        try await Task.sleep(seconds: 1)
        let request = MRequest {
          RUrl("http://127.0.0.1:8080")
            .withPath("todos")
            .withPath("paginate")
          RQueryItems(["page": page, "per": 5])
          RMethod(.get)
        }
          .printCURLRequest()
        let data = try await request.data
        log.json(data)
        let pageModel = data.toModel(Page<Todo>.self) ?? Page(items: [], metadata: .init(page: 0, per: 0, total: 0))
        let pagedResponse: PagedResponse<Todo> = PagedResponse(page: page, totalPages: pageModel.metadata.totalPages, results: pageModel.items)
        return pagedResponse
      }
      
      let _ = useAsync(.once) {
        try await loadmore.load()
      }
      
      let todos = useNextPhaseValue(loadmore.loadPhase) ?? []
      let status = useOnceExistedPhaseStatusSuccess(loadmore.loadPhase) ?? .pending
      
      switch status {
        case .pending:
          ProgressView()
        case .success, .running:
          List {
            ForEach(todos) { todo in
              Toggle(isOn: .constant(todo.isCompleted)) {
                TextField("", text: .constant(todo.text)) {
                }
                .textFieldStyle(.plain)
#if os(iOS) || os(macOS)
                .textFieldStyle(.roundedBorder)
#endif
              }
              .padding(.vertical, 4)
            }
            viewLoadMore(loadmore: loadmore)
          }
          .listStyle(.grouped)
          .refreshable {
            do {
              try await loadmore.load()
            } catch {
              
            }
          }
          .navigationTitle("Total: " + todos.count.description + " isloading: \(loadmore.isLoading.description)")
          .navigationBarTitleDisplayMode(.inline)
        case .failure:
          Text("failure")
      }
    }
  }
}

struct PagedIDResponseTodo: View {
  var body: some View {
    HookScope {
      let loadmore: LoadMoreIdentifiedArray<Todo> = useLoadMoreHookIDModel(firstPage: 1) { page in
        try await Task.sleep(seconds: 1)
        let request = MRequest {
          RUrl("http://127.0.0.1:8080")
            .withPath("todos")
            .withPath("paginate")
          RQueryItems(["page": page, "per": 5])
          RMethod(.get)
        }
          .printCURLRequest()
        let data = try await request.data
        log.json(data)
        let pageModel = data.toModel(Page<Todo>.self) ?? Page(items: [], metadata: .init(page: 0, per: 0, total: 0))
        let pagedResponse: PagedIDResponse<Todo> = PagedIDResponse(page: page, totalPages: pageModel.metadata.totalPages, results: pageModel.items.toIdentifiedArray())
        return pagedResponse
      }
      
      let _ = useAsync(.once) {
        try await loadmore.load()
      }
      
      let todos = useNextPhaseValue(loadmore.loadPhase) ?? []
      let status = useOnceExistedPhaseStatusSuccess(loadmore.loadPhase) ?? .pending
      
      switch status {
        case .pending:
          ProgressView()
        case .success, .running:
          List {
            ForEach(todos) { todo in
              Toggle(isOn: .constant(todo.isCompleted)) {
                TextField("", text: .constant(todo.text)) {
                }
                .textFieldStyle(.plain)
#if os(iOS) || os(macOS)
                .textFieldStyle(.roundedBorder)
#endif
              }
              .padding(.vertical, 4)
            }
            viewLoadMore(loadmore: loadmore)
          }
          .listStyle(.grouped)
          .refreshable {
            do {
              try await loadmore.load()
            } catch {
              
            }
          }
          .navigationTitle("Total: " + todos.count.description + " isloading: \(loadmore.isLoading.description)")
          .navigationBarTitleDisplayMode(.inline)
        case .failure:
          Text("failure")
      }
    }
  }
}

struct HookPageTodo: View {
  
  var body: some View {
    HookScope {
      let loadmore: LoadMoreAray<Todo> = useLoadMorePage(firstPage: 1) { page in
        try await Task.sleep(seconds: 1)
        let request = MRequest {
          RUrl("http://127.0.0.1:8080")
            .withPath("todos")
            .withPath("paginate")
          RQueryItems(["page": page, "per": 5])
          RMethod(.get)
        }
          .printCURLRequest()
        let data = try await request.data
        log.json(data)
        return data.toModel(Page<Todo>.self) ?? Page(items: [], metadata: .init(page: 0, per: 0, total: 0))
      }
      
      let _ = useAsync(.once) {
        try await loadmore.load()
      }
      
      let todos = useNextPhaseValue(loadmore.loadPhase) ?? []
      let status = useOnceExistedPhaseStatusSuccess(loadmore.loadPhase) ?? .pending
      
      switch status {
        case .pending:
          ProgressView()
        case .success, .running:
          List {
            ForEach(todos) { todo in
              Toggle(isOn: .constant(todo.isCompleted)) {
                TextField("", text: .constant(todo.text)) {
                }
                .textFieldStyle(.plain)
#if os(iOS) || os(macOS)
                .textFieldStyle(.roundedBorder)
#endif
              }
              .padding(.vertical, 4)
            }
            viewLoadMore(loadmore: loadmore)
          }
          .listStyle(.grouped)
          .refreshable {
            do {
              try await loadmore.load()
            } catch {
              
            }
          }
          .navigationTitle("Total: " + todos.count.description + " isloading: \(loadmore.isLoading.description)")
          .navigationBarTitleDisplayMode(.inline)
        case .failure:
          Text("failure")
      }
    }
  }
}

#Preview {
    HookLoadMoreView()
}

/// Tabs organize content across different data sets in a screens.
public struct FTabBar<Content: View>: View {
  
  let tabs: [TabItemData]
  @Binding var selectedIndex: Int
  @ViewBuilder let content: (Int) -> Content
  
  public init(tabs: [TabItemData], selectedIndex: Binding<Int>, content: @escaping (Int) -> Content) {
    self.tabs = tabs
    self._selectedIndex = selectedIndex
    self.content = content
  }
  
  public var body: some View {
    VStack {
      TabView(selection: $selectedIndex) {
        ForEach(tabs.indices, id: \.self) { index in
          content(index)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .tag(index)
            .simultaneousGesture(
              DragGesture()
            )
            .eraseToAnyView()
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
      TabBottomView(tabbarItems: tabs, selectedIndex: $selectedIndex)
        .padding(.bottom, 0)
        .ignoresSafeArea()
    }
    .onFirstAppear {
      
    }
    .onLastDisappear {
      
    }
  }
}

public struct TabItemData {
  let image: String
  let selectedImage: String
  let title: String
  
  public init(image: String, selectedImage: String, title: String) {
    self.image = image
    self.selectedImage = selectedImage
    self.title = title
  }
}

struct TabItemView: View {
  let data: TabItemData
  let isSelected: Bool
  
  var body: some View {
    VStack {
      Image(systemName: "list.bullet")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 24, height: 24)
        .onAppear{
          withAnimation(.default) {
          }
        }
        .foregroundColor(isSelected ? Color(red: 0.06, green: 0.50, blue: 0.93) : Color(red: 0.27, green: 0.32, blue: 0.37))
      Spacer()
        .frame(height: 4)
      
      Text(data.title)
        .foregroundColor(isSelected ? Color(red: 0.06, green: 0.50, blue: 0.93) : Color(red: 0.27, green: 0.32, blue: 0.37))
    }
  }
}


struct TabBottomView: View {
  let tabbarItems: [TabItemData]
  var height: CGFloat = 48
  var width: CGFloat = UIScreen.main.bounds.width
  @Binding var selectedIndex: Int
  
  var tabIndices: Range<Int> {
    return 0..<tabbarItems.count
  }
  
  var body: some View {
    HStack {
      Spacer()
      ForEach(tabIndices, id: \.self) { index in
        let item = tabbarItems[index]
        Button {
          self.selectedIndex = index
        } label: {
          let isSelected = selectedIndex == index
          TabItemView(data: item, isSelected: isSelected)
        }
        Spacer()
      }
    }
    .frame(width: width, height: height)
  }
}
