import Foundation
import XCTest
import ComposableArchitecture

@MainActor
final class UseLoadMoreHookModelTests: XCTestCase {
  
  // MARK: Test UseLoadMoreHookModel
  func test_useLoadMoreHookModel() async throws {
    let results = ["A", "B", "C"]
    let tester = HookTester {
      let loadmore = useLoadMoreHookModel<String> { page in
        try await Task.sleep(seconds: 1)
        let pagedResponse = PagedResponse(page: page, totalPages: 100, results: ["A", "B", "C"])
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
      let values2: [String] = Array(repeating: results, count: 2).flatMap { $0 }
      XCTAssertEqual(tester.value.loadPhase.value, values2)
      // loadMore
      try await tester.value.loadNext()
      await sleep(timeout: 2)
      let values3: [String] = Array(repeating: results, count: 3).flatMap { $0 }
      XCTAssertEqual(tester.value.loadPhase.value, values3)
      // loadFirst
      try await tester.value.load()
      await sleep(timeout: 2)
      XCTAssertEqual(tester.value.loadPhase.value, results)
    }
  }
}
