import Foundation
import SwiftUI
import IdentifiedCollections

/// A single section of a larger, traversable result set.
public struct Page<T> {
  /// The page's items. Usually models.
  public let items: [T]
  
  /// Metadata containing information about current page, items per page, and total items.
  public let metadata: PageMetadata
  
  /// Creates a new `Page`.
  public init(items: [T], metadata: PageMetadata) {
    self.items = items
    self.metadata = metadata
  }
  
  /// Maps a page's items to a different type using the supplied closure.
  public func map<U>(_ transform: (T) throws -> (U)) rethrows -> Page<U> {
    try .init(
      items: self.items.map(transform),
      metadata: self.metadata
    )
  }
}

extension Page: Encodable where T: Encodable {}
extension Page: Decodable where T: Decodable {}

/// Metadata for a given `Page`.
public struct PageMetadata: Codable {
  /// Current page number. Starts at `1`.
  public let page: Int
  
  /// Max items per page.
  public let per: Int
  
  /// Total number of items available.
  public let total: Int
  
  /// Computed total number of pages with `1` being the minimum.
  public var pageCount: Int {
    let count = Int((Double(self.total)/Double(self.per)).rounded(.up))
    return count < 1 ? 1 : count
  }
  
  /// Creates a new `PageMetadata` instance.
  ///
  /// - Parameters:
  ///.  - page: Current page number.
  ///.  - per: Max items per page.
  ///.  - total: Total number of items available.
  public init(page: Int, per: Int, total: Int) {
    self.page = page
    self.per = per
    self.total = total
  }
  
  public var hasNextPage: Bool {
    self.page * self.per < total
  }
  
  public var totalPages: Int {
    pageCount
  }
}

/// Represents information needed to generate a `Page` from the full result set.
public struct PageRequest: Codable {
  /// Page number to request. Starts at `1`.
  public let page: Int
  
  /// Max items per page.
  public let per: Int
  
  enum CodingKeys: String, CodingKey {
    case page = "page"
    case per = "per"
  }
  
  /// `Decodable` conformance.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.page = try container.decodeIfPresent(Int.self, forKey: .page) ?? 1
    self.per = try container.decodeIfPresent(Int.self, forKey: .per) ?? 10
  }
  
  /// Crates a new `PageRequest`
  /// - Parameters:
  ///   - page: Page number to request. Starts at `1`.
  ///   - per: Max items per page.
  public init(page: Int, per: Int) {
    self.page = page
    self.per = per
  }
  
  var start: Int {
    (self.page - 1) * self.per
  }
  
  var end: Int {
    self.page * self.per
  }
}


public func useLoadMorePage<Model: Equatable>(
  firstPage: Int = 1,
  _ loader: @escaping () -> (Int) async throws -> Page<Model>
) -> LoadMoreHookModel<Model> {
  useLoadMorePage(firstPage: firstPage, loader())
}

public func useLoadMorePage<Model: Equatable>(
  firstPage: Int = 1,
  _ loader: @escaping (Int) async throws -> Page<Model>
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
    nextModels += loadNextPhase.value?.items ?? []
    return nil
  }
  
  return LoadMoreHookModel(
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
