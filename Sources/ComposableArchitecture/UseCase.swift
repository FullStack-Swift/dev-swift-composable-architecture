import Combine
import Foundation

public protocol UseCaseProtocol {

  associatedtype Input

  associatedtype Output

  func execute(_ input: Input) -> AnyPublisher<Output, Error>

}
public extension UseCaseProtocol where Self.Input == Void {
  func execute() -> AnyPublisher<Output, Error> {
    return execute(())
  }
}

public protocol AsyncUseCaseProtocol {

  associatedtype Input

  associatedtype Output

  func execute(_ input: Input) async throws -> Output

}
public extension AsyncUseCaseProtocol where Self.Input == Void {
  func execute() async throws -> Output {
    try await execute(())
  }
}
