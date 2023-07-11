import Foundation
import Combine
import SwiftUI

public struct RiverpodContext {
  
  private(set) weak var weakStore: RiverpodStore?
  
  /// A callback to perform when any of atoms watched by this context is updated.
  public let objectWillChange = PassthroughSubject<Void, Never>()
  
  init() {
    
  }
  
  init(weakStore: RiverpodStore? = nil) {
    self.weakStore = weakStore ?? .init()
  }
  
  static func scoped(store: RiverpodStore) -> Self {
    Self.init(weakStore: store)
  }
  
  public func sendChange() {
    objectWillChange.send()
  }
  
  @discardableResult
  public func watch<Node: ProviderProtocol>(_ node: Node) -> Node.Value  {
    if let node = store.state[id: node.id]?.wrapped as? Node {
      return node.value
    } else {
      store.state.updateOrAppend(node.eraseAnyProvider())
      sendChange()
      return node.value
    }
  }
  
  @discardableResult
  public func read<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    if let node = store.state[id: node.id]?.wrapped as? Node {
      return node.value
    } else {
      sendChange()
      store.state.updateOrAppend(node.eraseAnyProvider())
      return node.value
    }
  }
  
  @discardableResult
  public func set<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    sendChange()
    store.state.updateOrAppend(node.eraseAnyProvider())
    return node.value
  }
  
  @discardableResult
  public func binding<Node: ProviderProtocol>(_ node: Node) -> Binding<Node.Value> {
    Binding {
      read(node)
    } set: { newValue in
      node.value = newValue
      set(node)
    }

  }
  
  var store: RiverpodStore {
    weakStore ?? .shared
  }
}

class RiverpodStore {
  static let shared = RiverpodStore()
  var state = IdentifiedArrayOf<AnyProvider>()
}
