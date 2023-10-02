public protocol BaseState: Equatable {
  
}

public protocol BaseIDState: BaseState, Identifiable {
  
}

extension BaseState {
  public func with(_ block: (inout Self) -> Void) -> Self {
    var clone = self
    block(&clone)
    return clone
  }
}

extension BaseIDState {
  public var idString: String {
    id.rawValue.toString()
  }
}
