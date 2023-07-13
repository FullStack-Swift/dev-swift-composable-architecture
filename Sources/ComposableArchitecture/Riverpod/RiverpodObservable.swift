import Combine
import SwiftUI

public class RiverpodObservable: BaseObservable {

  @Dependency(\.riverpodContext) var context

  override init() {
    super.init()
//    context
//      .objectWillChange
//      .sink(receiveValue: sendChange)
//      .store(in: &cancellables)
  }
  
  deinit {
      print("RiverpodObservable has deinit")
  }
  
  @discardableResult
  public func watch<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    context.watch(node)
  }
  
  @discardableResult
  public func binding<Node: ProviderProtocol>(_ node: Node) -> Binding<Node.Value> {
    return context.binding(node)
    
  }
  
  @discardableResult
  public func read<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    context.read(node)
  }
  
  @discardableResult
  public func set<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    context.set(node)
  }
  
  @discardableResult
  public func modify<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    fatalError()
  }
  
  @discardableResult
  public func refresh<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    fatalError()
  }
  
  @discardableResult
  public func reset<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    fatalError()
  }
  
  @discardableResult
  public func pull<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    fatalError()
  }
  
  public func removeAll() {
    self.context.removeAll()
  }
}
