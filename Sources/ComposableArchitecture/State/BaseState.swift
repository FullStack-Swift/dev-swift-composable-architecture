public protocol PrototypeProtocol {}

extension PrototypeProtocol {
  public func with(_ block: (inout Self) -> Void) -> Self {
    var clone = self
    block(&clone)
    return clone
  }

  public func apply(_ block: (inout Self) -> Void) -> Self {
    ComposableArchitecture.apply(block, to: self)
  }
}

public protocol BaseState: Equatable, PrototypeProtocol {

}

public protocol BaseIDState: BaseState, Identifiable {

}
