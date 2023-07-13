import Foundation
import Combine
import SwiftUI

public struct RiverpodContext {
  
  private(set) weak var weakStore: RiverpodStore?
  
  /// A callback to perform when any of atoms watched by this context is updated.
  public let objectWillChange = PassthroughSubject<Void, Never>()
  
  private var cancellables = Set<AnyCancellable>()
  
  init() {
    
  }
  
  init(weakStore: RiverpodStore? = nil) {
    self.weakStore = weakStore ?? .init()
    weakStore?.state.sink(receiveValue: { [self] _ in
      self.objectWillChange.send()
    })
    .store(in: &cancellables)
  }
  
  static func scoped(store: RiverpodStore) -> Self {
    Self.init(weakStore: store)
    
  }
  
  @discardableResult
  public func watch<Node: ProviderProtocol>(_ node: Node) -> Node.Value  {
    if let node = store.state.value[id: node.id]?.wrapped as? Node {
      return node.value
    } else {
      store.state.value.updateOrAppend(node.eraseAnyProvider())
      return node.value
    }
  }
  
  @discardableResult
  public func read<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    if let node = store.state.value[id: node.id]?.wrapped as? Node {
      return node.value
    } else {
      store.state.value.updateOrAppend(node.eraseAnyProvider())
      return node.value
    }
  }
  
  @discardableResult
  public func set<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    store.state.value.updateOrAppend(node.eraseAnyProvider())
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
  
  public func removeAll() {
    store.state.value.removeAll()
  }
  
  var store: RiverpodStore {
    weakStore ?? .shared
  }
}
