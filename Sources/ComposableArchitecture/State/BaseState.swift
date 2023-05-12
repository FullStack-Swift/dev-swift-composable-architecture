public protocol PrototypeProtocol {}

public extension PrototypeProtocol {
  func with(_ block: (inout Self) -> Void) -> Self {
    var clone = self
    block(&clone)
    return clone
  }

  func apply(_ block: (inout Self) -> Void) -> Self {
    ComposableArchitecture.apply(block, to: self)
  }
}

protocol BaseState: Equatable, PrototypeProtocol {

}

protocol BaseIDState: BaseState, Identifiable {

}
