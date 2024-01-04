import Foundation
import SwiftUI
import IdentifiedCollections

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

private func useLoadModels<Model>(
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
