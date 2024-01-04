import Foundation
import SwiftUI
import IdentifiedCollections

// MARK: LoadMoreIdentifiedArray
// ==========================================================================================
///
///- The hook func to loadMore Items with ``Array``.
///```swift
///let loadmore: LoadMoreIdentifiedArray<Todo> = useLoadMoreIdentifiedArray(firstPage: 1) { page in
///   try await Task.sleep(seconds: 1)
///   let request = MRequest {
///     RUrl("http://127.0.0.1:8080")
///       .withPath("todos")
///       .withPath("paginate")
///     RQueryItems(["page": page, "per": 5])
///     RMethod(.get)
///   }
///  .printCURLRequest()
///   let data = try await request.data
///   log.json(data)
///   let pageModel = data.toModel(Page<Todo>.self) ?? Page(items: [], metadata: .init(page: 0, per: 0, total: 0))
///   let pagedResponse: PagedIdentifiedArray<Todo> = PagedIdentifiedArray(page: page, totalPages: pageModel.metadata.totalPages, results: pageModel.items.toIdentifiedArray())
///   return pagedResponse
///}
///```
///
public func useLoadMoreIdentifiedArray<Model>(
  firstPage: Int = 1,
  _ loader: @escaping () -> (Int) async throws -> PagedIdentifiedArray<Model>
) -> LoadMoreIdentifiedArray<Model> where Model: Identifiable, Model: Equatable {
  useLoadMoreIdentifiedArray(firstPage: firstPage, loader())
}

public func useLoadMoreIdentifiedArray<Model>(
  firstPage: Int = 1,
  _ loader: @escaping (Int) async throws -> PagedIdentifiedArray<Model>
) -> LoadMoreIdentifiedArray<Model> where Model: Identifiable, Model: Equatable {
  
  @HRef
  var isLoading = false
  
  @HRef
  var nextModels = IdentifiedArrayOf<Model>()
  
  /// loader first phase.
  let (loadPhase, load) = useLoadIdentifiedArray(Model.self, firstPage: firstPage, loader)
  
  /// loader next phase.
  let (loadNextPhase, loadNext) = useLoadIdentifiedArray(Model.self, firstPage: firstPage, loader)
  
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
  
  return LoadMoreIdentifiedArray(
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

private func useLoadIdentifiedArray<Model: Identifiable>(
  _ type: Model.Type,
  firstPage: Int,
  _ loader: @escaping( (Int) async throws -> PagedIdentifiedArray<Model>)
) -> (phase: AsyncPhase<PagedIdentifiedArray<Model>, Error>, load: (Int) async throws -> Void) {
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



// MARK: LoadMore Array
// ==========================================================================================
///- The hook func to loadMore Items with ``Array``.
///```swift
///      let loadmore: LoadMoreAray<Todo> = useLoadMoreAray(firstPage: 1) { page in
///         try await Task.sleep(seconds: 1)
///         let request = MRequest {
///           RUrl("http://127.0.0.1:8080")
///             .withPath("todos")
///             .withPath("paginate")
///            RQueryItems(["page": page, "per": 5])
///            RMethod(.get)
///          }
///           .printCURLRequest()
///         let data = try await request.data
///         log.json(data)
///         let pageModel = data.toModel(Page<Todo>.self) ?? Page(items: [], metadata: .init(page: 0, per: 0, total: 0))
///         let pagedResponse: PagedResponse<Todo> = PagedResponse(page: page, totalPages: pageModel.metadata.totalPages, results: pageModel.items)
///         return pagedResponse
///      }
///```
///
public func useLoadMoreAray<Model: Equatable>(
  firstPage: Int = 1,
  _ loader: @escaping () -> (Int) async throws -> PagedResponse<Model>
) -> LoadMoreAray<Model> {
  useLoadMoreAray(firstPage: firstPage, loader())
}

public func useLoadMoreAray<Model: Equatable>(
  firstPage: Int = 1,
  _ loader: @escaping (Int) async throws -> PagedResponse<Model>
) -> LoadMoreAray<Model> {
  
  @HRef
  var isLoading = false
  
  @HRef
  var nextModels = [Model]()
  
  /// loader first phase.
  let (loadPhase, load) = useLoadArray(Model.self, firstPage: firstPage, loader)
  
  /// loader next phase.
  let (loadNextPhase, loadNext) = useLoadArray(Model.self, firstPage: firstPage, loader)
  
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
  
  return LoadMoreAray(
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

private func useLoadArray<Model>(
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

// MARK: LoadMorePage
//==========================================================================================
///- The hook func to loadMore with ``Page`` in Vapor.
///```swift
///let loadmore: LoadMoreAray<Todo> = useLoadMorePage(firstPage: 1) { page in
///try await Task.sleep(seconds: 1)
///let request = MRequest {
///  RUrl("http://127.0.0.1:8080")
///    .withPath("todos")
///    .withPath("paginate")
///  RQueryItems(["page": page, "per": 5])
///  RMethod(.get)
///}
/// .printCURLRequest()
///let data = try await request.data
///log.json(data)
///return data.toModel(Page<Todo>.self) ?? Page(items: [], metadata: .init(page: 0, per: 0, total: 0))
///}
///```
///
public func useLoadMorePage<Model: Equatable>(
  firstPage: Int = 1,
  _ loader: @escaping () -> (Int) async throws -> Page<Model>
) -> LoadMoreAray<Model> {
  useLoadMorePage(firstPage: firstPage, loader())
}

public func useLoadMorePage<Model: Equatable>(
  firstPage: Int = 1,
  _ loader: @escaping (Int) async throws -> Page<Model>
) -> LoadMoreAray<Model> {
  @HRef
  var isLoading = false
  
  @HRef
  var nextModels = [Model]()
  
  /// loader first phase.
  let (loadPhase, load) = useLoadPage(Model.self, firstPage: firstPage, loader)
  
  /// loader next phase.
  let (loadNextPhase, loadNext) = useLoadPage(Model.self, firstPage: firstPage, loader)
  
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
    nextModels += loadNextPhase.value?.items ?? []
    return nil
  }
  
  return LoadMoreAray(
    isLoading: isLoading,
    loadPhase: loadPhase.map {
      $0.items + nextModels
    },
    hasNextPage: latestResponse?.metadata.hasNextPage ?? false,
    load: {
      if isLoading { return }
      isLoading = true
      try await load(firstPage)
    },
    loadNext: {
      if let currentPage = latestResponse?.metadata.page {
        if isLoading { return }
        isLoading = true
        try await loadNext(currentPage + 1)
      }
    }
  )
}

private func useLoadPage<Model>(
  _ type: Model.Type,
  firstPage: Int,
  _ loader: @escaping( (Int) async throws -> Page<Model>)
) -> (phase: AsyncPhase<Page<Model>, Error>, load: (Int) async throws -> Void) {
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
