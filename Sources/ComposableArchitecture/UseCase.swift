import Combine
import Foundation

public protocol PublisherUseCaseProtocol {

  associatedtype Input

  associatedtype Output
  
  associatedtype Failure: Error

  func run(_ input: Input) -> AnyPublisher<Output, Failure>

}

public extension PublisherUseCaseProtocol where Self.Input == Void {
  func run() -> AnyPublisher<Output, Failure> {
    return run(())
  }
}

public protocol AsyncUseCaseProtocol {

  associatedtype Input

  associatedtype Output

  func run(_ input: Input) async -> Output

}

public extension AsyncUseCaseProtocol where Self.Input == Void {
  func run() async -> Output {
    await run(())
  }
}

public protocol ThrowingAsyncUseCaseProtocol {
  
  associatedtype Input
  
  associatedtype Output
  
  func run(_ input: Input) async throws -> Output
  
}

public extension ThrowingAsyncUseCaseProtocol where Self.Input == Void {
  func run() async throws -> Output {
    try await run(())
  }
}

public protocol IOUseCaseProtocol {
  
  associatedtype Input
  
  associatedtype Output
  
  func run(_ input: Input) -> IO<Output>
}

extension IOUseCaseProtocol where Self.Input == Void {
  func run(_ input: ()) ->IO<Output> {
    run(input)
  }
}
