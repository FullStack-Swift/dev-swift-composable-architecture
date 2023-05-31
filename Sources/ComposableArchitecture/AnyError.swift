import Foundation

public struct AnyError<Failure: Error>: Error {

  public var error: Failure

  public init(error: Failure) {
    self.error = error
  }
}

public extension Error {
  func asAnyError() -> AnyError<Self> {
    AnyError(error: self)
  }
}

extension AnyError: Equatable where Failure: Equatable {}
