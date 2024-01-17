import Foundation
///
/// Base Protocol for LoadMore, it is base properties for loadmore for all implement in template, when we implement ``LoadMoreProtocol`` we can using ``LoadMoreView`` in base project.
///
public protocol LoadMoreProtocol {
  /// A success, storeing in a ``AsyncPhase``
  associatedtype Success
  /// A status is loading data from async await
  var isLoading: Bool { get }
  /// phase for loadmore
  var loadPhase: AsyncPhase<Success, Error> { get }
  /// return if it has load next page.
  var hasNextPage: Bool { get }
  /// a async await function for load first, or refreshing a ``View``
  var load: ThrowingAsyncCompletion { get }
  /// a sync await function for load next data.
  var loadNext: ThrowingAsyncCompletion { get }
}

///
/// A implement for ``LoadMoreProtocol`` for`` Array`` in Swift.
///
public struct LoadMoreAray<Model>: LoadMoreProtocol {
  public let isLoading: Bool
  public let loadPhase: AsyncPhase<[Model], Error>
  public let hasNextPage: Bool
  public let load: ThrowingAsyncCompletion
  public let loadNext: ThrowingAsyncCompletion
  
  public init(
    isLoading: Bool,
    loadPhase: AsyncPhase<[Model], Error>,
    hasNextPage: Bool,
    load: @escaping ThrowingAsyncCompletion,
    loadNext: @escaping ThrowingAsyncCompletion
  ) {
    self.isLoading = isLoading
    self.loadPhase = loadPhase
    self.hasNextPage = hasNextPage
    self.load = load
    self.loadNext = loadNext
  }
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


///
/// A implement for ``LoadMoreProtocol`` for ``IdentifiedArray`` in Swift.
///
public struct LoadMoreIdentifiedArray<Model: Identifiable>: LoadMoreProtocol {
  public let isLoading: Bool
  public let loadPhase: AsyncPhase<IdentifiedArrayOf<Model>, Error>
  public let hasNextPage: Bool
  public let load: ThrowingAsyncCompletion
  public let loadNext: ThrowingAsyncCompletion
  
  public init(
    isLoading: Bool,
    loadPhase: AsyncPhase<IdentifiedArrayOf<Model>, Error>,
    hasNextPage: Bool,
    load: @escaping ThrowingAsyncCompletion,
    loadNext: @escaping ThrowingAsyncCompletion
  ) {
    self.isLoading = isLoading
    self.loadPhase = loadPhase
    self.hasNextPage = hasNextPage
    self.load = load
    self.loadNext = loadNext
  }
}

public struct PagedIdentifiedArray<T: Identifiable> {
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

extension PagedIdentifiedArray: Encodable where T: Encodable {}

extension PagedIdentifiedArray: Decodable where T: Decodable {}

extension PagedIdentifiedArray: Equatable where T: Equatable {}

extension PagedIdentifiedArray: Hashable where T: Hashable {}

public struct AnyLoadMoreHookModel<Success>: LoadMoreProtocol {
  public let isLoading: Bool
  public let loadPhase: AsyncPhase<Success, Error>
  public let hasNextPage: Bool
  public let load: ThrowingAsyncCompletion
  public let loadNext: ThrowingAsyncCompletion
  
  public init(
    isLoading: Bool,
    loadPhase: AsyncPhase<Success, Error>,
    hasNextPage: Bool,
    load: @escaping ThrowingAsyncCompletion,
    loadNext: @escaping ThrowingAsyncCompletion
  ) {
    self.isLoading = isLoading
    self.loadPhase = loadPhase
    self.hasNextPage = hasNextPage
    self.load = load
    self.loadNext = loadNext
  }
  
  public init<T: LoadMoreProtocol>(loadMore: T) where T.Success == Success {
    self.isLoading = loadMore.isLoading
    self.loadPhase = loadMore.loadPhase
    self.hasNextPage = loadMore.hasNextPage
    self.load = loadMore.load
    self.loadNext = loadMore.loadNext
  }
}

public protocol HPageProtocol {
  /// The type of items that this items returns.
  associatedtype Success
  
  /// current page number. Starts at `1`.
  var page: Int { get }
  
  /// Total number of page avaliable.
  var totalPages: Int { get }
  /// The pages's items. Usualy models
  var results: [Success] { get }
}

public extension HPageProtocol {
  
  /// return ``Page`` frome SwiftExt
  func toPage() -> Page<Success> {
    Page(
      items: results,
      metadata: PageMetadata(page: page, per: 20, total: totalPages)
    )
  }
  
  var hasNextPage: Bool {
    page < totalPages
  }
}

public struct HAnyPage<T>: HPageProtocol {
  public let page: Int
  public let totalPages: Int
  public let results: [T]
  
  public init(page: Int, totalPages: Int, results: [T]) {
    self.page = page
    self.totalPages = totalPages
    self.results = results
  }
}

extension HAnyPage : Equatable where T: Equatable {}

extension HAnyPage: Sendable where T: Sendable {}

extension HAnyPage: Encodable where T: Encodable {}

extension HAnyPage: Decodable where T: Decodable {}

extension HAnyPage: Hashable where T: Hashable {}
