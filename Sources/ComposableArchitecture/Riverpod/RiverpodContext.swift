import Foundation
import Combine
import SwiftUI

public struct RiverpodContext {
  
  private(set) weak var weakStore: RiverpodStore?
  
  init() {
    
  }
  
  init(weakStore: RiverpodStore? = nil) {
    self.weakStore = weakStore ?? .init()
  }
  
  static func scoped(store: RiverpodStore) -> Self {
    Self.init(weakStore: store)
  }
  
  public func watch<Node: ProviderProtocol>(_ node: Node) -> Node.Value  {
    guard let store = weakStore else {
      fatalError()
    }
    if let node = store.states.compactMap({$0 as? Node}).filter({$0 === node}).first {
      return node.value
    } else {
        store.states.append(node)
    }
    return node.value
  }
}

class RiverpodStore {
  static let shared = RiverpodStore()
  var states = [any ProviderProtocol]()
}

extension RiverpodStore {
  struct StoreState {
    
    var states = [any ProviderProtocol]()
  }
}

public class Ref {
  
}
