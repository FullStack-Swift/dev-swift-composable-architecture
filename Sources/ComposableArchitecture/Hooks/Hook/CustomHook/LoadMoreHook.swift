import Foundation
import SwiftUI

public struct LoadMoreHookModel<Model> {
  public let selectedMovie: Binding<Model?>
  public let loadPhase: HookAsyncPhase<[Model], Error>
  public let hasNextPage: Bool
  public let load: () async -> Void
  public let loadNext: () async -> Void
}

public struct PagedResponse<T> {
  public let page: Int
  public let totalPages: Int
  public let results: [T]
  
  public var hasNextPage: Bool {
    page < totalPages
  }
}

extension PagedResponse: Decodable where T: Decodable {}

extension PagedResponse: Equatable where T: Equatable {}

public func useLoadMoreHookModel<Model>(_ loader: @escaping () -> () async throws -> PagedResponse<Model>) -> LoadMoreHookModel<Model> {
  useLoadMoreHookModel(loader())
}

public func useLoadMoreHookModel<Model>(_ loader: @escaping () async throws -> PagedResponse<Model>) -> LoadMoreHookModel<Model> {
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
      await load(1)
    },
    loadNext: {
      if let currentPage = latestResponse?.page {
        await loadNext(currentPage + 1)
      }
    }
  )
}

private func useLoadModels<Model>(
  _ type: Model.Type,
  _ loader: @escaping( () async throws -> PagedResponse<Model>)
) -> (phase: HookAsyncPhase<PagedResponse<Model>, Error>, load: (Int) async -> Void) {
  let page = useRef(0)
  let (phase, load) = useAsyncPerform { [loader] in
    return try await loader()
  }
  
  return (
    phase: phase,
    load: { newPage in
      page.current = newPage
      await load()
    }
  )
}
