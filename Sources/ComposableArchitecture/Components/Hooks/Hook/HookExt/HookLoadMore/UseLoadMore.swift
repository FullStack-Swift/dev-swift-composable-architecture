import Foundation
import SwiftUI
import IdentifiedCollections

// MARK: LoadMore ID
// ==========================================================================================

public func useLoadMoreHookIDModel<Model>(
  firstPage: Int = 1,
  _ loader: @escaping () -> (Int) async throws -> PagedIDResponse<Model>
) -> LoadMoreIdentifiedArray<Model> where Model: Identifiable, Model: Equatable {
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
) -> LoadMoreIdentifiedArray<Model> where Model: Identifiable, Model: Equatable {
  
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



// MARK: LoadMore Array
// ==========================================================================================

public func useLoadMoreHookModel<Model: Equatable>(
  firstPage: Int = 1,
  _ loader: @escaping () -> (Int) async throws -> PagedResponse<Model>
) -> LoadMoreAray<Model> {
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
) -> LoadMoreAray<Model> {
  
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

// MARK: Refresh LoadMore Array
// ==========================================================================================

public func useLoadMoreHookRefreshModel<Model: Equatable>(
  firstPage: Int = 1,
  _ loader: @escaping () -> (Int) async throws -> PagedResponse<Model>
) -> LoadMoreAray<Model> {
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
) -> LoadMoreAray<Model> {
  
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
