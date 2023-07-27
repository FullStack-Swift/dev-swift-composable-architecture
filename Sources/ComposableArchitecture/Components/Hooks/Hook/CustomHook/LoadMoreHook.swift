import Foundation
import SwiftUI

public struct LoadMoreHookModel<Model> {
  public let selectedMovie: Binding<Model?>
  public let loadPhase: HookAsyncPhase<[Model], Error>
  public let hasNextPage: Bool
  public let load: () async throws -> Void
  public let loadNext: () async throws -> Void
}

public struct PagedResponse<T> {
  public let page: Int
  public let totalPages: Int
  public let results: [T]
  
  public var hasNextPage: Bool {
    page < totalPages
  }
}

extension PagedResponse: Encodable where T: Encodable {}

extension PagedResponse: Decodable where T: Decodable {}

extension PagedResponse: Equatable where T: Equatable {}

extension PagedResponse: Hashable where T: Hashable {}

extension PagedResponse: Sendable where T: Sendable {}

/// LoadMoreModel
/// - Parameter loader:
/// page  = 1 => LoadFirst
/// page > 1 => LoadMore
/// - Returns: `LoadMoreHookModel`
public func useLoadMoreHookModel<Model>(
  _ loader: @escaping () -> (Int) async throws -> PagedResponse<Model>
) -> LoadMoreHookModel<Model> {
  useLoadMoreHookModel(loader())
}

/// LoadMoreModel
/// - Parameter loader:
/// page  = 1 => LoadFirst
/// page > 1 => LoadMore
/// - Returns: `LoadMoreHookModel
public func useLoadMoreHookModel<Model>(
  _ loader: @escaping (Int) async throws -> PagedResponse<Model>
) -> LoadMoreHookModel<Model> {
  
  let selectedMovie = useState(nil as Model?)
  
  let nextMovies = useRef([Model]())
  
  let (loadPhase, load) = useLoadModels(Model.self, loader)
  
  let (loadNextPhase, loadNext) = useLoadModels(Model.self, loader)
  
  let latestResponse = loadNextPhase.value ?? loadPhase.value
  
  useLayoutEffect(.preserved(by: loadPhase.isSuccess)) {
    nextMovies.current = []
    return nil
  }
  
  useLayoutEffect(.preserved(by: loadNextPhase.isSuccess)) {
    nextMovies.current += loadNextPhase.value?.results ?? []
    return nil
  }
  
  return LoadMoreHookModel(
    selectedMovie: selectedMovie,
    loadPhase: loadPhase.map {
      $0.results + nextMovies.current
    },
    hasNextPage: latestResponse?.hasNextPage ?? false,
    load: {
      try await load(1)
    },
    loadNext: {
      if let currentPage = latestResponse?.page {
        try await loadNext(currentPage + 1)
      }
    }
  )
}

private func useLoadModels<Model>(
  _ type: Model.Type,
  _ loader: @escaping( (Int) async throws -> PagedResponse<Model>)
) -> (phase: HookAsyncPhase<PagedResponse<Model>, Error>, load: (Int) async throws -> Void) {
  let page = useRef(0)
  let (phase, fetch) = useAsyncPerform { [loader] in
    return try await loader(page.current)
  }
  return (
    phase: phase,
    load: { newPage in
      page.current = newPage
      fetch()
    }
  )
}
