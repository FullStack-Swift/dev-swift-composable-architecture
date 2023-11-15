import SwiftUI

/// Called after the view is loaded into memory.
public func useOnFistAppear( _ callBack:  @escaping () -> Void) {
  useInital(.once, callBack)
}

/// Notifies the view that its view was removed from a view hierarchy.
public func useOnLastAppear(_ callBack: @escaping () -> Void) {
  useDispose(.once, callBack)
}

@propertyWrapper
public struct HOnFirstAppear {
  
  public var wrappedValue: () -> ()
  
  public init(wrappedValue: @escaping () -> Void) {
    self.wrappedValue = wrappedValue
    useOnFistAppear(wrappedValue)
  }
  
}


@propertyWrapper
public struct HOnLastAppear {
  
  public var wrappedValue: () -> ()
  
  public init(wrappedValue: @escaping () -> Void) {
    self.wrappedValue = wrappedValue
    useOnLastAppear(wrappedValue)
  }
  
}
