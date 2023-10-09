import Foundation
import SwiftUI
import IdentifiedCollections

// MARK: LoadMore ID

public func useLoadMoreHookIDModel<Model: Identifiable>(
  _ loader: @escaping () -> (Int) async throws -> PagedIDResponse<Model>
) -> LoadMoreHookIDModel<Model> {
  useLoadMoreHookIDModel(loader())
}

public func useLoadMoreHookIDModel<Model>(
  _ loader: @escaping (Int) async throws -> PagedIDResponse<Model>
) -> LoadMoreHookIDModel<Model> {
  let selectedModel = useState(nil as Model?)
  
  let nextModels = useRef([Model]())
  
  let (loadPhase, load) = useLoadIDModels(Model.self, loader)
  
  let (loadNextPhase, loadNext) = useLoadIDModels(Model.self, loader)
  
  let latestResponse = loadNextPhase.value ?? loadPhase.value
  
  useLayoutEffect(.preserved(by: loadPhase.isSuccess)) {
    nextModels.current = []
    return nil
  }
  
  useLayoutEffect(.preserved(by: loadNextPhase.isSuccess)) {
    nextModels.current += loadNextPhase.value?.results ?? []
    return nil
  }
  
  return LoadMoreHookIDModel(
    selectedModel: selectedModel,
    loadPhase: loadPhase.map {
      $0.results + nextModels.current
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

private func useLoadIDModels<Model: Identifiable>(
  _ type: Model.Type,
  _ loader: @escaping( (Int) async throws -> PagedIDResponse<Model>)
) -> (phase: HookAsyncPhase<PagedIDResponse<Model>, Error>, load: (Int) async throws -> Void) {
  let page = useRef(0)
  let (phase, fetch) = useAsyncPerform { [loader] in
    return try await loader(page.current)
  }
  return (
    phase: phase,
    load: { newPage in
      page.current = newPage
      return try await fetch()
    }
  )
}

/// Description
public struct LoadMoreHookIDModel<Model: Identifiable> {
  public let selectedModel: Binding<Model?>
  public let loadPhase: HookAsyncPhase<IdentifiedArrayOf<Model>, Error>
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
  
  let selectedModel = useState(nil as Model?)
  
  let nextModels = useRef([Model]())
  
  let (loadPhase, load) = useLoadModels(Model.self, loader)
  
  let (loadNextPhase, loadNext) = useLoadModels(Model.self, loader)
  
  let latestResponse = loadNextPhase.value ?? loadPhase.value
  
  useLayoutEffect(.preserved(by: loadPhase.isSuccess)) {
    nextModels.current = []
    return nil
  }
  
  useLayoutEffect(.preserved(by: loadNextPhase.isSuccess)) {
    nextModels.current += loadNextPhase.value?.results ?? []
    return nil
  }
  
  return LoadMoreHookModel(
    selectedModel: selectedModel,
    loadPhase: loadPhase.map {
      $0.results + nextModels.current
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
      return try await fetch()
    }
  )
}

/// Description
public struct LoadMoreHookModel<Model> {
  public let selectedModel: Binding<Model?>
  public let loadPhase: HookAsyncPhase<[Model], Error>
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
