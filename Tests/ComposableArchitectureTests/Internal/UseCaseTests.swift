import Combine
import ComposableArchitecture
import XCTest

@testable import ComposableArchitecture

struct RandomPublisherUseCase: PublisherUseCaseProtocol {
  
  typealias Input = Int
  
  typealias Output = String
  
  typealias Failure = Never
  
  func run(_ input: Int) -> AnyPublisher<Output, Failure> {
    Just(input.description)
      .eraseToAnyPublisher()
  }
}

struct RandomAsyncUseCase: AsyncUseCaseProtocol {
  typealias Input = Int
  
  typealias Output = String
  
  func run(_ input: Int) async -> String {
    try! await Task.sleep(nanoseconds: 1*MSEC_PER_SEC)
    return input.description
  }
}

struct RandomThrowingAsyncUseCase: ThrowingAsyncUseCaseProtocol {
  
  typealias Input = Int
  
  typealias Output = String
  
  func run(_ input: Int) async throws -> String {
    try await Task.sleep(nanoseconds: 1*MSEC_PER_SEC)
    return input.description
  }
}

struct RandomIOUseCase: IOUseCaseProtocol {
  typealias Input = Int
  
  typealias Output = String
  
  func run(_ input: Int) -> IO<String> {
    let io = IO<String> { handler in
      Task {
        try await Task.sleep(nanoseconds: 1*MSEC_PER_SEC)
        handler.dispatch(.init(input.description))
      }
    }
    return io
  }
  
}

final class UseCaseTests: BaseTCATestCase {
  
  var cancellables: Set<AnyCancellable> = []
  
  func testRandomPublisherUseCase() {
    let random = Int.random(in: 1...10000)
    let usecase = RandomPublisherUseCase()
    usecase.run(random).sink { value in
      XCTAssertEqual(random.description, value)
    }
    .store(in: &cancellables)
  }
  
  func testRandomAsyncUseCase() async {
    let random = Int.random(in: 1...10000)
    let usecase = RandomAsyncUseCase()
    let value = await usecase.run(random)
    XCTAssertEqual(random.description, value)
  }
  
  func testThrowingRandomAsyncUseCase() async throws {
    let random = Int.random(in: 1...10000)
    let usecase = RandomThrowingAsyncUseCase()
    let value = try await usecase.run(random)
    XCTAssertEqual(random.description, value)
  }
  
  func testRandomIOUseCase() {
    let random = Int.random(in: 1...10000)
    let usecase = RandomIOUseCase()
    usecase.run(random).on { dispatch in
      XCTAssertEqual(random.description, dispatch.action)
    }
  }
}
