import Combine
import SwiftUI

public class RiverpodObservable: BaseObservable {
  
  @Dependency(\.riverpodContext) var context
  
  private let location: SourceLocation
  
  public var isPresented: Bool = false
  
  init(location: SourceLocation) {
    self.location = location
  }
  
  public init(fileID: String = #fileID, line: UInt = #line) {
    location = SourceLocation(fileID: fileID, line: line)
    super.init()
    context.subscribe(id: id)
    context.observable.publisher
//      .filter({$0.ids.contains(self.id)})
      .void()
      .sink(receiveValue: refresh)
      .store(in: &cancellables)
  }
  
  public override func refresh() {
    if isPresented {
      super.refresh()
    }
  }
}

// MARK: riverpod function
extension RiverpodObservable {
  @discardableResult
  public func watch<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
//    context.subscribe(id: id)
    node.observable.sink {
      self.refresh()
    }
    return context.watch(node)
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
  public func update<Node: ProviderProtocol>(node: Node, newValue: Node.Value) -> Node.Value {
    context.update(node: node, newValue: newValue)
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

// MARK: lifecycle for SwiftUI.
extension RiverpodObservable {
  
  public func onAppear() {
//    isPresented = true
  }
  
  public func onDisappear() {
//    isPresented = false
  }
  
  public func onFirstAppear() {
    
  }
  
  public func onLastDisappear() {
    context.unsubscribe(id: id)
  }
}
