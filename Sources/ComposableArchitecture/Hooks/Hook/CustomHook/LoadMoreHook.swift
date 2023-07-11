import Foundation
import SwiftUI

public struct LoadMoreHookModel<Model> {
  let selectedMovie: Binding<Model?>
  let loadPhase: HookAsyncPhase<[Model], Error>
  let hasNextPage: Bool
  let load: () async -> Void
  let loadNext: () async -> Void
}

struct PagedResponse<T> {
  let page: Int
  let totalPages: Int
  let results: [T]
  
  var hasNextPage: Bool {
    page < totalPages
  }
}

extension PagedResponse: Decodable where T: Decodable {}

extension PagedResponse: Equatable where T: Equatable {}

public func useLoadMoreHookModel<Model>() -> LoadMoreHookModel<Model> {
  let selectedMovie = useState(nil as Model?)
  let nextMovies = useRef([Model]())
  let (loadPhase, load) = useLoadModels(Model.self)
  let (loadNextPhase, loadNext) = useLoadModels(Model.self)
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
  _ type: Model.Type
) -> (phase: HookAsyncPhase<PagedResponse<Model>, Error>, load: (Int) async -> Void) {
  let page = useRef(0)
  let (phase, load) = useAsyncPerform {
    try await Task.sleep(nanoseconds: 1_000_000_000)
    print(page.current)
    return PagedResponse<Model>(page: 0, totalPages: 0, results: [])
  }
  
  return (
    phase: phase,
    load: { newPage in
      page.current = newPage
      await load()
    }
  )
}
