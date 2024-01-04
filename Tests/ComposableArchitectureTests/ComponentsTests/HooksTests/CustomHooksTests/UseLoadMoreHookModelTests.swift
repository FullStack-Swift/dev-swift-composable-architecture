import Foundation
import XCTest
import ComposableArchitecture

@MainActor
final class UseLoadMoreHookModelTests: XCTestCase {
  
  // MARK: Test UseLoadMoreHookModel
  func test_useLoadMoreHookModel() async throws {
    let results = ["A", "B", "C"].map({TodoModel(text: $0)})
    let tester = HookTester {
      let loadmore: LoadMoreAray<TodoModel> = useLoadMoreAray(firstPage: 1) { page in
        try await Task.sleep(seconds: 1)
        let pagedResponse = PagedResponse(page: page, totalPages: 100, results: results)
        return pagedResponse
      }
      return loadmore
    }
    
    do {
      // loadFirst
      try await tester.value.load()
      await sleep(timeout: 2)
      XCTAssertEqual(tester.value.loadPhase.value, results)
      // loadMore
      try await tester.value.loadNext()
      await sleep(timeout: 2)
      let values2: [TodoModel] = Array(repeating: results, count: 2).flatMap { $0 }
      XCTAssertEqual(tester.value.loadPhase.value, values2)
      // loadMore
      try await tester.value.loadNext()
      await sleep(timeout: 2)
      let values3: [TodoModel] = Array(repeating: results, count: 3).flatMap { $0 }
      XCTAssertEqual(tester.value.loadPhase.value, values3)
      // loadFirst
      try await tester.value.load()
      await sleep(timeout: 2)
      XCTAssertEqual(tester.value.loadPhase.value, results)
    }
  }
  
  // MARK: Test UseLoadMoreHookModel
  func test_useLoadMoreHookIDModel() async throws {
    let results = ["A", "B", "C"].map({TodoModel(text: $0)}).toIdentifiedArray()
    let tester = HookTester {
      let loadmore: LoadMoreIdentifiedArray<TodoModel> = useLoadMoreIdentifiedArray(firstPage: 1) { page in
        try await Task.sleep(seconds: 1)
        let pagedResponse = PagedIdentifiedArray(page: page, totalPages: 100, results: results)
        return pagedResponse
      }
      return loadmore
    }
    
    do {
      // loadFirst
      try await tester.value.load()
      await sleep(timeout: 2)
      XCTAssertEqual(tester.value.loadPhase.value, results)
      // loadMore
      try await tester.value.loadNext()
      await sleep(timeout: 2)
      let values2 = Array(repeating: results, count: 2).flatMap { $0 }.toIdentifiedArray()
      XCTAssertEqual(tester.value.loadPhase.value, values2)
      // loadMore
      try await tester.value.loadNext()
      await sleep(timeout: 2)
      let values3 = Array(repeating: results, count: 3).flatMap { $0 }.toIdentifiedArray()
      XCTAssertEqual(tester.value.loadPhase.value, values3)
      // loadFirst
      try await tester.value.load()
      await sleep(timeout: 2)
      XCTAssertEqual(tester.value.loadPhase.value, results)
    }
  }
}

fileprivate struct TodoModel: Codable, Equatable , Identifiable {
  var id: UUID = UUID()
  var text: String = ""
  var isCompleted: Bool = false
}
