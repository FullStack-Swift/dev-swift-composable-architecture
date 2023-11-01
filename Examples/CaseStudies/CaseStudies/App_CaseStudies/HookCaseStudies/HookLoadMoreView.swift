import SwiftUI

struct HookLoadMoreView: View {
  
  let tabs = [
    TabItemData(image: "ic_tab",selectedImage: "ic_tab_selected",title: "useID"),
    TabItemData(image: "ic_tab", selectedImage: "ic_tab_selected", title: "useArray"),
    TabItemData(image: "ic_tab", selectedImage: "ic_tab_selected", title: "useID"),
    TabItemData(image: "ic_tab", selectedImage: "ic_tab_selected", title: "useArray")
  ]
  
  var body: some View {
    HookScope {
      let selectedTab = useState(0)
      FTabBar(tabs: tabs, selectedIndex: selectedTab) { index in
        VStack {
          if index == 0 {
            loadMoreIDContent
          } else if index == 1 {
            loadMoreContent
          } else if index == 2 {
            loadMoreIDContent
          } else if index == 3 {
            loadMoreContent
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
  
  @ViewBuilder
  var loadMoreIDContent: some View {
    HookScope {
      let loadmore: LoadMoreHookIDModel<UserModel> = useLoadMoreHookIDModel(firstPage: 1) { page in
        try await Task.sleep(seconds: 1)
        var results: [UserModel] = []
        for index in 0...Int.random(in: 1...5) {
          results.append(UserModel(email: "Page: \(page) , index: " + index.description, phonenumber: index.description))
        }
        let pagedResponse: PagedIDResponse<UserModel> = PagedIDResponse(page: page, totalPages: 10, results: results.toIdentifiedArray())
        return pagedResponse
      }
      
      let _ = useAsync(.once) {
        try await loadmore.load()
      }
      
      let users = useNextPhaseValue(loadmore.loadPhase) ?? []
      let status = useOnceExistedPhaseStatusSuccess(loadmore.loadPhase) ?? .pending
      
      switch status {
        case .pending:
          ProgressView()
        case .success, .running:
          List {
            ForEach(users) { item in
              NavigationLink {
                Text(item.email)
              } label: {
                Text(item.email)
              }
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
          .navigationTitle("Total: " + users.count.description + " isloading: \(loadmore.isLoading.description)")
          .navigationBarTitleDisplayMode(.inline)
        case .failure:
          Text("failure")
      }
    }
  }
  @ViewBuilder
  var loadMoreContent: some View {
    HookScope {
      let loadmore: LoadMoreHookModel<UserModel> = useLoadMoreHookModel(firstPage: 1) { page in
        try await Task.sleep(seconds: 1)
        var results: [UserModel] = []
        for index in 0...Int.random(in: 1...5) {
          results.append(UserModel(email: "Page: \(page) , index: " + index.description, phonenumber: index.description))
        }
        let pagedResponse: PagedResponse<UserModel> = PagedResponse(page: page, totalPages: 10, results: results)
        return pagedResponse
      }
      
      let _ = useAsync(.once) {
        try await loadmore.load()
      }
      
      let users = useNextPhaseValue(loadmore.loadPhase) ?? []
      let status = useOnceExistedPhaseStatusSuccess(loadmore.loadPhase) ?? .pending
      
      switch status {
        case .pending:
          ProgressView()
        case .success, .running:
          List {
            ForEach(users) { item in
              NavigationLink {
                Text(item.email)
              } label: {
                Text(item.email)
              }
              
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
          .navigationTitle("Total: " + users.count.description + " isloading: \(loadmore.isLoading.description)")
          .navigationBarTitleDisplayMode(.inline)
        case .failure:
          Text("failure")
      }
    }
  }
  
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
