import Foundation
///
/// Base Protocol for LoadMore, it is base properties for loadmore for all implement in template, when we implement ``LoadMoreProtocol`` we can using ``LoadMoreView`` in base project.
///
public protocol LoadMoreProtocol {
  /// A success, storeing in a ``AsyncPhase``
  associatedtype Success
  /// A status is loading data from async await
  var isLoading: Bool {get}
  /// phase for loadmore
  var loadPhase: AsyncPhase<Success, Error> {get}
  /// return if it has load next page.
  var hasNextPage: Bool {get}
  /// a async await function for load first, or refreshing a ``View``
  var load: ThrowingAsyncCompletion {get}
  /// a sync await function for load next data.
  var loadNext: ThrowingAsyncCompletion {get}
}

///
/// A implement for ``LoadMoreProtocol`` for Array in Swift.
///
public struct LoadMoreAray<Model>: LoadMoreProtocol {
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


///
/// A implement for ``LoadMoreProtocol`` for IdentifiedArray in Swift.
///
public struct LoadMoreIdentifiedArray<Model: Identifiable>: LoadMoreProtocol {
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

//@available(iOS 16.0.0, *)
//public struct AnyLoadMoreHookModel<Model: Identifiable>: LoadMoreProtocol {
//  public typealias Success = any Collection<Model>
//  
//  public let isLoading: Bool
//  public let loadPhase: AsyncPhase<Success, Error>
//  public let hasNextPage: Bool
//  public let load: ThrowingAsyncCompletion
//  public let loadNext: ThrowingAsyncCompletion
//  
//  public init(isLoading: Bool,
//       loadPhase: AsyncPhase<Success, Error>,
//       hasNextPage: Bool,
//       load: @escaping ThrowingAsyncCompletion,
//       loadNext: @escaping ThrowingAsyncCompletion
//  ) {
//    self.isLoading = isLoading
//    self.loadPhase = loadPhase
//    self.hasNextPage = hasNextPage
//    self.load = load
//    self.loadNext = loadNext
//  }
//  
//  public init(loadMore: some LoadMoreProtocol) {
//    self.isLoading = loadMore.isLoading
////    self.loadPhase = loadMore.loadPhase
//    self.loadPhase = .pending
//    self.hasNextPage = loadMore.hasNextPage
//    self.load = loadMore.load
//    self.loadNext = loadMore.loadNext
//  }
//  
//}

public struct AnyPagedResponse<T: Identifiable> {
  public let page: Int
  public let totalPages: Int
  public let results: any Collection<T>
  
  public init(page: Int, totalPages: Int, results: any Collection<T>) {
    self.page = page
    self.totalPages = totalPages
    self.results = results
  }
  
  public var hasNextPage: Bool {
    page < totalPages
  }
}
