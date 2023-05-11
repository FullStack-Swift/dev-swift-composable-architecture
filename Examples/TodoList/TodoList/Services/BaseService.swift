import Foundation

public protocol ServiceProtocol {
  var path: String? { get set }
}

open class BaseService: ServiceProtocol {

  // MARK: Properties
  public var path: String?

  // MARK: Dependency
  @Dependency(\.uuid) var uuid
  @Dependency(\.urlString) var urlString

  public init(_ path: String? = nil) {
    self.path = path
  }

  @discardableResult
  open func withPath(path: String?) -> Self {
    self.path = path
    return self
  }

  open func read<ID: Identifiable>(_ id: ID) -> MRequest {
    MRequest {
      RUrl(urlString: urlString)
        .withPath(path)
        .withPath(String(describing: id))
      RMethod(.get)
    }
  }

  open func reads() -> MRequest {
    MRequest {
      RUrl(urlString: urlString)
        .withPath(path)
      RMethod(.get)
    }
  }

  open func create(_ data: Data) -> MRequest {
    MRequest {
      RUrl(urlString: urlString)
        .withPath(path)
      REncoding(JSONEncoding.default)
      RMethod(.post)
      Rbody(data)
    }
  }

  open func update<Model: Codable & Identifiable>(_ model: Model) -> MRequest {
    MRequest {
      RUrl(urlString: urlString)
        .withPath(path)
        .withPath(String(describing: model.id))
      RMethod(.post)
      Rbody(model.toData())
    }
  }

  open func delete<ID: Identifiable>(_ id: ID) -> MRequest {
    MRequest {
      RUrl(urlString: urlString)
        .withPath(path)
        .withPath(String(describing: id))
      RMethod(.delete)
    }

  }

}
