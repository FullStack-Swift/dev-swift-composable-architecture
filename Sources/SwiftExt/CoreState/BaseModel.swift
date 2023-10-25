import Foundation

public protocol BaseModel: Equatable {}

public protocol BaseIDModel: BaseModel, Identifiable {}

extension BaseModel {
  public func with(_ block: (inout Self) -> Void) -> Self {
    var clone = self
    block(&clone)
    return clone
  }
}

extension BaseIDModel {
  public var idString: String {
    String(describing: Self.ID.self)
  }
}
