import Foundation
import Combine
import SwiftUI

@MainActor
public protocol RiverpodContextProtocol {
  
  func read<Node: ProviderProtocol>(_ node: Node) -> Node.Value
  
  func set<Node: StateAtom>(_ node: Node) -> Node.Value
}

public class RiverpodContext {
  
  private(set) weak var weakStore: RiverpodStore?
  
  private var cancellables = SetCancellables()
  
  @StateListener<IdentifiedArrayOf<SubscribeId>>(wrappedValue: [])
  var observable
  
  var _ids = IdentifiedArrayOf<SubscribeId>()

  init() {
    
  }
  
  deinit {

  }
  
  init(weakStore: RiverpodStore? = nil) {
    self.weakStore = weakStore ?? .init()
    weakStore?.state
//      .map({_ in self._ids})
//      .sink(receiveValue: $observable.send)
      .sink(receiveValue: { providers in
        for item in providers {
          item.wrapped.observable.sink {
            let id = self._ids
//            self.$observable.send(id)
          }
        }
      })
      .store(in: &cancellables)
  }
  
  static func scoped(store: RiverpodStore) -> RiverpodContext {
    RiverpodContext.init(weakStore: store)
  }
  
  func subscribes(ids: [UUID]) {
    for id in ids {
      _ids.updateOrAppend(SubscribeId(id: id))
    }
  }
  
  func unsubscribes(ids: [UUID]) {
    for id in ids {
      _ids.remove(id: id)
    }
  }
  
  func subscribe(id: UUID) {
    subscribes(ids: [id])
  }
  
  func unsubscribe(id: UUID) {
    unsubscribes(ids: [id])
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
    if let node = store.state.value[id: node.id]?.wrapped as? Node {
      return node.value
    } else {
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
    return newNode.value
  }
  
  @discardableResult
  public func binding<Node: ProviderProtocol>(_ node: Node) -> Binding<Node.Value> {
    Binding {
      self.watch(node)
    } set: { newValue in
      self.update(node: node, newValue: newValue)
    }
  }
  
  @discardableResult
  public func state<Node: ProviderProtocol>(_ node: Node) -> Binding<Node.Value> {
    Binding {
      self.watch(node)
    } set: { newValue in
      self.update(node: node, newValue: newValue)
    }
  }
  
  public func removeAll() {
    store.state.value.removeAll()
  }
  
  var store: RiverpodStore {
    weakStore ?? .identity
  }
}
