import Combine
import Foundation

public protocol UseCaseProtocol {

  associatedtype Input

  associatedtype Output

  func run(_ input: Input) -> AnyPublisher<Output, any Error>

}
public extension UseCaseProtocol where Self.Input == Void {
  func run() -> AnyPublisher<Output, any Error> {
    return run(())
  }
}

public protocol AsyncUseCaseProtocol {

  associatedtype Input

  associatedtype Output

  func run(_ input: Input) async throws -> Output

}
public extension AsyncUseCaseProtocol where Self.Input == Void {
  func run() async throws -> Output {
    try await run(())
  }
}
