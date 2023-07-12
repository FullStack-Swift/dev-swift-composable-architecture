import Combine
import SwiftUI

public class RiverpodObservable: ObservableObject {

  private var cancellables = Set<AnyCancellable>()
  
  @Dependency(\.riverpodContext) var riverpodContext
  
  public private(set) lazy var objectWillChange = ObservableObjectPublisher()
  
  deinit {
    riverpodContext.store.state.removeAll()
  }
  
  init() {
    objectWillChange
      .subscribe(riverpodContext.objectWillChange)
      .store(in: &cancellables)
  }
  
  @discardableResult
  public func watch<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    subscribe(publisher: node)
      .store(in: &cancellables)
    return riverpodContext.watch(node)
  }
  
  @discardableResult
  public func watch<Value, Node: StateNotifierProvider<Value>>(_ node: Node) -> Value.Value {
    subscribe(publisher: node)
      .store(in: &cancellables)
    subscribe(publisher: node.state)
      .store(in: &cancellables)
    return riverpodContext.watch(node)
  }
  
  @discardableResult
  public func binding<Node: ProviderProtocol>(_ node: Node) -> Binding<Node.Value> {
    subscribe(publisher: node)
      .store(in: &cancellables)
    return riverpodContext.binding(node)
    
  }
  
  @discardableResult
  public func read<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    riverpodContext.read(node)
  }
  
  @discardableResult
  public func set<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    riverpodContext.set(node)
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
    
  public func removeAll() {
    self.riverpodContext.store.state.removeAll()
  }
}
