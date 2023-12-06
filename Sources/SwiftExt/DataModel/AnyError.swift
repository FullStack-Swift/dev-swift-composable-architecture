import Foundation

public struct AnyError<Failure: Error>: Error {

  public var error: Failure

  public init(error: Failure) {
    self.error = error
  }
}

public extension Error {
  func eraseToAnyError() -> AnyError<Self> {
    AnyError(error: self)
  }
}

extension AnyError: Decodable where Failure: Decodable {}

extension AnyError: Encodable where Failure: Encodable {}

extension AnyError: Equatable where Failure: Equatable {}

extension AnyError: Hashable where Failure: Hashable {}

extension AnyError: Sendable where Failure: Sendable {}

public struct MError: Error {
  
  public var code: Int
  public var message: String
  
  public init(code: Int, message: String) {
    self.code = code
    self.message = message
  }
}

extension MError: Equatable {}
extension MError: Codable {}
extension MError: Sendable {}
