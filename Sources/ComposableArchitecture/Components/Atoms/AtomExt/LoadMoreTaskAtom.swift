import SwiftUI
import Combine

public class LoadMoreObservableAtom<Model>: ObservableObject {
  
  public typealias Success = PagedResponse<Model>

  @Published
  public private(set) var isLoading: Bool  = false
  
  @Published
  public private(set) var isRefresh: Bool  = false
  
  @Published
  public private(set) var loadPhase: AsyncPhase<PagedResponse<Model>, Error> = .pending
  
  private let loader: ((Int) async throws -> PagedResponse<Model>)
  
  private var firstPage: Int
  
  private var currentPage: Int
  
  public init(
    firstPage: Int = 1,
    _ loader: @escaping( (Int) async throws -> PagedResponse<Model>)
  ) {
    self.firstPage = firstPage
    self.currentPage = firstPage
    self.loader = loader
  }
  
  @MainActor
  public func loadFirst() async throws {
    /// set to load first
    currentPage = firstPage
    isLoading = true
    self.loadPhase = .pending
    /// update to phase
    self.loadPhase = await AsyncPhase {
      try await loader(firstPage)
    }
    isLoading = false
  }
  
  @MainActor
  public func loadNext() async throws {
    /// check condition load next.
    guard loadPhase.value?.hasNextPage == true else { return }
    guard currentPage < (loadPhase.value?.totalPages ?? 0) else { return }
    guard !isLoading else { return }
    currentPage += 1
    isLoading = true
    let models = loadPhase.value?.results ?? []
    
    /// update to phase
    self.loadPhase = await AsyncPhase {
      try await loader(currentPage)
    }
    .map { pageResponse in
      PagedResponse(page: pageResponse.page, totalPages: pageResponse.totalPages, results: pageResponse.results + models)
    }
    isLoading = false
  }
  
  @MainActor
  public func refresh() async throws {
    
    /// check condition
    guard currentPage > firstPage else {
      try await loadFirst()
      return
    }
    
    guard !isRefresh else { return }
    isRefresh = true
    
    /// perform async
    let pageResponse = try await withThrowingTaskGroup(of: PagedResponse<Model>.self, returning: PagedResponse<Model>.self) { taskGroup in
      for page in firstPage...currentPage {
        taskGroup.addTask {
          await AsyncPhase {
            try await self.loader(page)
          }
          .value ?? PagedResponse(page: 0, totalPages: 0, results: [])
        }
      }
      var items = [PagedResponse<Model>]()
      for try await item in taskGroup {
        items.append(item)
      }
      items = items.sorted { $0.page < $1.page}
      let totalPages = self.loadPhase.value?.totalPages ?? 0
      let results = items.compactMap({$0.results}).flatMap({$0})
      return PagedResponse(page: currentPage, totalPages: totalPages, results: results)
    }
    /// update to phase
    self.loadPhase = .success(pageResponse)
    isRefresh = false
  }
}
