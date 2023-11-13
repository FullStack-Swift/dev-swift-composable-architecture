import Foundation
import SwiftUI
import IdentifiedCollections

// MARK: LoadMore ID
// ==========================================================================================

public func useLoadMoreHookIDModel<Model>(
  firstPage: Int = 1,
  _ loader: @escaping () -> (Int) async throws -> PagedIDResponse<Model>
) -> LoadMoreHookIDModel<Model> where Model: Identifiable, Model: Equatable {
  useLoadMoreHookIDModel(firstPage: firstPage, loader())
}

/// use loadmore with ID:
///```swift
///     let loadmore: LoadMoreHookIDModel<TodoModel> = useLoadMoreHookIDModel(firstPage: 1) { page in
///
///     }
///```
///
/// desciption: something
public func useLoadMoreHookIDModel<Model>(
  firstPage: Int = 1,
  _ loader: @escaping (Int) async throws -> PagedIDResponse<Model>
) -> LoadMoreHookIDModel<Model> where Model: Identifiable, Model: Equatable {
  
  @HRef
  var isLoading = false
  
  @HRef
  var nextModels = IdentifiedArrayOf<Model>()
  
  // loader first phase.
  let (loadPhase, load) = useLoadIDModels(Model.self, firstPage: firstPage, loader)
  
  // loader next phase.
  let (loadNextPhase, loadNext) = useLoadIDModels(Model.self, firstPage: firstPage, loader)
  
  var latestResponse = loadNextPhase.value ?? loadPhase.value
  
  useLayoutEffect(.preserved(by: loadPhase.status)) {
    if loadPhase.hasResponded {
      isLoading = false
      latestResponse = loadPhase.value
    }
    return nil
  }
  
  useLayoutEffect(.preserved(by: loadNextPhase.status)) {
    if loadNextPhase.hasResponded {
      isLoading = false
    }
    return nil
  }
  
  useLayoutEffect(.preserved(by: loadPhase.isSuccess)) {
    nextModels = []
    latestResponse = loadPhase.value
    return nil
  }
  
  useLayoutEffect(.preserved(by: loadNextPhase.isSuccess)) {
    nextModels += loadNextPhase.value?.results ?? []
    return nil
  }
  
  return LoadMoreHookIDModel(
    isLoading: isLoading,
    loadPhase: loadPhase.map {
      $0.results + nextModels
    },
    hasNextPage: latestResponse?.hasNextPage ?? false,
    load: {
      if isLoading { return }
      isLoading = true
      try await load(firstPage)
    },
    loadNext: {
      if let currentPage = latestResponse?.page {
        if isLoading { return }
        isLoading = true
        try await loadNext(currentPage + 1)
      }
    }
  )
}

private func useLoadIDModels<Model: Identifiable>(
  _ type: Model.Type,
  firstPage: Int,
  _ loader: @escaping( (Int) async throws -> PagedIDResponse<Model>)
) -> (phase: AsyncPhase<PagedIDResponse<Model>, Error>, load: (Int) async throws -> Void) {
  @HRef var page = firstPage
  let (phase, fetch) = useAsyncPerform { [loader] in
    return try await loader(page)
  }
  return (
    phase: phase,
    load: { newPage in
      page = newPage
      return try await fetch()
    }
  )
}

public struct LoadMoreHookIDModel<Model: Identifiable>: LoadMoreProtocol {
  public let isLoading: Bool
  public let loadPhase: AsyncPhase<IdentifiedArrayOf<Model>, Error>
  public let hasNextPage: Bool
  public let load: ThrowingAsyncCompletion
  public let loadNext: ThrowingAsyncCompletion
}

public struct PagedIDResponse<T: Identifiable> {
  public let page: Int
  public let totalPages: Int
  public let results: IdentifiedArrayOf<T>
  
  public init(page: Int, totalPages: Int, results: IdentifiedArrayOf<T>) {
    self.page = page
    self.totalPages = totalPages
    self.results = results
  }
  
  public var hasNextPage: Bool {
    page < totalPages
  }
}

extension PagedIDResponse: Encodable where T: Encodable {}

extension PagedIDResponse: Decodable where T: Decodable {}

extension PagedIDResponse: Equatable where T: Equatable {}

extension PagedIDResponse: Hashable where T: Hashable {}


// MARK: LoadMore Array
// ==========================================================================================

public func useLoadMoreHookModel<Model: Equatable>(
  firstPage: Int = 1,
  _ loader: @escaping () -> (Int) async throws -> PagedResponse<Model>
) -> LoadMoreHookModel<Model> {
  useLoadMoreHookModel(firstPage: firstPage, loader())
}

/// use loadmore:
///
///       let loadmore: LoadMoreHookModel<TodoModel> = useLoadMoreHookModel(firstPage: 1) { page in
///
///       }
///
/// desciption: something
public func useLoadMoreHookModel<Model: Equatable>(
  firstPage: Int = 1,
  _ loader: @escaping (Int) async throws -> PagedResponse<Model>
) -> LoadMoreHookModel<Model> {
  
  @HRef
  var isLoading = false
  
  @HRef
  var nextModels = [Model]()
  
  // loader first phase.
  let (loadPhase, load) = useLoadModels(Model.self, firstPage: firstPage, loader)
  
  // loader next phase.
  let (loadNextPhase, loadNext) = useLoadModels(Model.self, firstPage: firstPage, loader)
  
  var latestResponse = loadNextPhase.value ?? loadPhase.value
  
  useLayoutEffect(.preserved(by: loadPhase.status)) {
    if loadPhase.hasResponded {
      isLoading = false
      latestResponse = loadPhase.value
    }
    return nil
  }
  
  useLayoutEffect(.preserved(by: loadNextPhase.status)) {
    if loadNextPhase.hasResponded {
      isLoading = false
    }
    return nil
  }
  
  useLayoutEffect(.preserved(by: loadPhase.isSuccess)) {
    nextModels = []
    latestResponse = loadPhase.value
    return nil
  }
  
  useLayoutEffect(.preserved(by: loadNextPhase.isSuccess)) {
    nextModels += loadNextPhase.value?.results ?? []
    return nil
  }
  
  return LoadMoreHookModel(
    isLoading: isLoading,
    loadPhase: loadPhase.map {
      $0.results + nextModels
    },
    hasNextPage: latestResponse?.hasNextPage ?? false,
    load: {
      if isLoading { return }
      isLoading = true
      try await load(firstPage)
    },
    loadNext: {
      if let currentPage = latestResponse?.page {
        if isLoading { return }
        isLoading = true
        try await loadNext(currentPage + 1)
      }
    }
  )
}

private func useLoadModels<Model>(
  _ type: Model.Type,
  firstPage: Int,
  _ loader: @escaping( (Int) async throws -> PagedResponse<Model>)
) -> (phase: AsyncPhase<PagedResponse<Model>, Error>, load: (Int) async throws -> Void) {
  @HRef var page = firstPage
  let (phase, fetch) = useAsyncPerform {
    return try await loader(page)
  }
  return (
    phase: phase,
    load: { newPage in
      page = newPage
      return try await fetch()
    }
  )
}

public struct LoadMoreHookModel<Model>: LoadMoreProtocol {
  public let isLoading: Bool
  public let loadPhase: AsyncPhase<[Model], Error>
  public let hasNextPage: Bool
  public let load: ThrowingAsyncCompletion
  public let loadNext: ThrowingAsyncCompletion
}

public struct PagedResponse<T> {
  public let page: Int
  public let totalPages: Int
  public let results: [T]
  
  public init(page: Int, totalPages: Int, results: [T]) {
    self.page = page
    self.totalPages = totalPages
    self.results = results
  }
  
  public var hasNextPage: Bool {
    page < totalPages
  }
}

extension PagedResponse: Encodable where T: Encodable {}

extension PagedResponse: Decodable where T: Decodable {}

extension PagedResponse: Equatable where T: Equatable {}

extension PagedResponse: Hashable where T: Hashable {}

extension PagedResponse: Sendable where T: Sendable {}

public protocol LoadMoreProtocol {
  
  associatedtype Success
  
  var isLoading: Bool {get}
  var loadPhase: AsyncPhase<Success, Error> {get}
  var hasNextPage: Bool {get}
  var load: ThrowingAsyncCompletion {get}
  var loadNext: ThrowingAsyncCompletion {get}
  
}


public struct LoadMoreView<
  LoadingContent: View,
  MoreContent: View,
  EndContent: View
>: MView {
  
  var loadmore: (any LoadMoreProtocol)?
  
  let loadingContent: () -> LoadingContent
  let moreContent: () -> MoreContent
  let endContent: () -> EndContent
  
  private var onTap: MCallBack?
  
  public init(
    loadmore: (any LoadMoreProtocol)? = nil,
    loadingContent: @escaping () -> LoadingContent,
    moreContent: @escaping () -> MoreContent,
    endContent: @escaping () -> EndContent
  ) {
    self.loadingContent = loadingContent
    self.moreContent = moreContent
    self.endContent = endContent
    self.loadmore = loadmore
  }
  
  public var anyBody: any View {
    IfLet(loadmore) { loadmore in
      HStack {
        If(loadmore.isLoading) {
          loadingContent()
            .alignment(horizontal: .center)
        } false: {
          Button {
            
          } label: {
            If(loadmore.hasNextPage) {
              moreContent()
            } false: {
              endContent()
            }
          }
          .disabled(!loadmore.hasNextPage)
          .onAppear {
            Task {
              if loadmore.hasNextPage {
                try await loadmore.loadNext()
              }
            }
          }
          .alignment(horizontal: .center)
        }
      }
    }
    .ifLet(onTap) { value, view in
      view.onTap {
        value?()
      }
    }
  }
  
  public func withLoadMore(loadmore: (any LoadMoreProtocol)? = nil) -> Self {
    with {
      $0.loadmore = loadmore
    }
  }
  
  public func onTap(_ onTap: @escaping MCallBack) -> Self {
    with {
      $0.onTap = onTap
    }
  }
}

// MARK: Refresh LoadMore Array
// ==========================================================================================

public func useLoadMoreHookRefreshModel<Model: Equatable>(
  firstPage: Int = 1,
  _ loader: @escaping () -> (Int) async throws -> PagedResponse<Model>
) -> LoadMoreHookModel<Model> {
  useLoadMoreHookModel(firstPage: firstPage, loader())
}

/// use loadmore:
///
///       let loadmore: LoadMoreHookModel<TodoModel> = useLoadMoreHookModel(firstPage: 1) { page in
///
///       }
///
/// desciption: something
public func useLoadMoreHookRefreshModel<Model: Equatable>(
  firstPage: Int = 1,
  _ loader: @escaping (Int) async throws -> PagedResponse<Model>
) -> LoadMoreHookModel<Model> {
  
  @HRef
  var isLoading = false
  
  @HRef
  var nextModels = [Model]()
  
  // loader first phase.
  let (loadPhase, load) = useLoadRefreshModels(Model.self, firstPage: firstPage, loader)
  
  // loader next phase.
  let (loadNextPhase, loadNext) = useLoadRefreshModels(Model.self, firstPage: firstPage, loader)
  
  var latestResponse = loadNextPhase.value ?? loadPhase.value
  
  useLayoutEffect(.preserved(by: loadPhase.status)) {
    if loadPhase.hasResponded {
      isLoading = false
      latestResponse = loadPhase.value
    }
    return nil
  }
  
  useLayoutEffect(.preserved(by: loadNextPhase.status)) {
    if loadNextPhase.hasResponded {
      isLoading = false
    }
    return nil
  }
  
  useLayoutEffect(.preserved(by: loadPhase.isSuccess)) {
    nextModels = []
    latestResponse = loadPhase.value
    return nil
  }
  
  useLayoutEffect(.preserved(by: loadNextPhase.isSuccess)) {
    nextModels += loadNextPhase.value?.results ?? []
    return nil
  }
  
  return LoadMoreHookModel(
    isLoading: isLoading,
    loadPhase: loadPhase.map {
      $0.results + nextModels
    },
    hasNextPage: latestResponse?.hasNextPage ?? false,
    load: {
      if isLoading { return }
      isLoading = true
      try await load(firstPage)
    },
    loadNext: {
      if let currentPage = latestResponse?.page {
        if isLoading { return }
        isLoading = true
        try await loadNext(currentPage + 1)
      }
    }
  )
}

private func useLoadRefreshModels<Model>(
  _ type: Model.Type,
  firstPage: Int,
  _ loader: @escaping( (Int) async throws -> PagedResponse<Model>)
) -> (phase: AsyncPhase<PagedResponse<Model>, Error>, load: (Int) async throws -> Void) {
  @HRef var page = firstPage
  let (phase, fetch) = useAsyncRefresh {
    return try await loader(page)
  }
  return (
    phase: phase,
    load: { newPage in
      page = newPage
      return try await fetch()
    }
  )
}
