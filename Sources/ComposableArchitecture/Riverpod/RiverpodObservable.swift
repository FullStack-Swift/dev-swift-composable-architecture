import Combine
import SwiftUI

public class RiverpodObservable: ObservableObject {
  
  var items: [any ProviderProtocol] = []
  
  private var cancellables = Set<AnyCancellable>()
  
  @Dependency(\.riverpodContext) var riverpodContext
  
  
  @discardableResult
  public func watch<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    riverpodContext.weakStore?.states.append(node)
    subscribe(publisher: node)
      .store(in: &cancellables)
    return node.value
  }
  
  @discardableResult
  public func watch<Value, Node: StateNotifierProvider<Value>>(_ node: Node) -> Value.Value {
    subscribe(publisher: node)
      .store(in: &cancellables)
    subscribe(publisher: node.state)
      .store(in: &cancellables)
    return node.value
  }
  
  @discardableResult
  public func binding<Node: ProviderProtocol>(_ node: Node) -> Binding<Node.Value> {
    subscribe(publisher: node)
      .store(in: &cancellables)
    return Binding {
      node.value
    } set: { newValue in
      node.value = newValue
    }
    
  }
  
  @discardableResult
  public func read<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    return node.value
  }
  
  @discardableResult
  public func set<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    return node.value
  }
  
  @discardableResult
  public func modify<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    return node.value
  }
  
  @discardableResult
  public func refresh<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    return node.value
  }
  
  @discardableResult
  public func reset<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    return node.value
  }
  
  @discardableResult
  public func pull<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    return node.value
  }
}
