import SwiftUI

public func useOnFistAppear( _ callBack:  @escaping () -> Void) {
  useInital(.once, callBack)
}

public func useOnLastAppear(_ callBack: @escaping () -> Void) {
  useDispose(.once, callBack)
}
