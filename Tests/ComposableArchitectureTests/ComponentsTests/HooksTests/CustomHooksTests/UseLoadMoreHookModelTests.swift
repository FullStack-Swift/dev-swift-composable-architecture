import Foundation
import XCTest
import ComposableArchitecture

@MainActor
final class UseLoadMoreHookModelTests: XCTestCase {
  
  // MARK: Test UseLoadMoreHookModel
  func test_useLoadMoreHookModel() async {
    let results = ["A", "B", "C"]
    let tester = HookTester {
      let loadmore = useLoadMoreHookModel<String> { page in
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let pagedResponse = PagedResponse(page: page, totalPages: 100, results: ["A", "B", "C"])
        return pagedResponse
      }
      return loadmore
    }
    
    do {
      // loadFirst
      tester.value.load()
      await sleep(timeout: 2)
      XCTAssertEqual(tester.value.loadPhase.value, results)
      // loadMore
      tester.value.loadNext()
      await sleep(timeout: 2)
      let values2: [String] = Array(repeating: results, count: 2).flatMap { $0 }
      XCTAssertEqual(tester.value.loadPhase.value, values2)
      // loadMore
      tester.value.loadNext()
      await sleep(timeout: 2)
      let values3: [String] = Array(repeating: results, count: 3).flatMap { $0 }
      XCTAssertEqual(tester.value.loadPhase.value, values3)
      // loadFirst
      tester.value.load()
      await sleep(timeout: 2)
      XCTAssertEqual(tester.value.loadPhase.value, results)
    }
  }
}
