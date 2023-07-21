import Foundation
import Combine
import SwiftUI

public struct RiverpodContext {
  
  private(set) weak var weakStore: RiverpodStore?
  
  private var cancellables = SetCancellables()
  
  @ObservableListener
  var observable
  
  init() {
    
  }
  
  init(weakStore: RiverpodStore? = nil) {
    self.weakStore = weakStore ?? .init()
    weakStore?.state.map({_ in ()})
      .sink(receiveValue: observable.send)
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
      node.observable.sink(observable.send)
      return node.value
    }
  }
  
  @discardableResult
  public func read<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    if let node = store.state.value[id: node.id]?.wrapped as? Node {
      return node.value
    } else {
      node.observable.sink(observable.send)
      store.state.value.updateOrAppend(node.eraseAnyProvider())
      return node.value
    }
  }
  
  @discardableResult
  public func set<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    if let node = store.state.value[id: node.id]?.wrapped as? Node {
      return node.value
    } else {
      node.observable.sink(observable.send)
      store.state.value.updateOrAppend(node.eraseAnyProvider())
      return node.value
    }
  }
  
  @discardableResult
  public func update<Node: ProviderProtocol>(node: Node, newValue: Node.Value) -> Node.Value {
    store.state.value.updateOrAppend(node.eraseAnyProvider())
    var newNode = node
    newNode.value = newValue
    store.state.value[id: node.id] = newNode.eraseAnyProvider()
    observable.send()
    return newNode.value
  }
  
  @discardableResult
  public func binding<Node: ProviderProtocol>(_ node: Node) -> Binding<Node.Value> {
    Binding {
      read(node)
    } set: { newValue in
      update(node: node, newValue: newValue)
    }
  }
  
  public func removeAll() {
    store.state.value.removeAll()
  }
  
  var store: RiverpodStore {
    weakStore ?? .identity
  }
}
