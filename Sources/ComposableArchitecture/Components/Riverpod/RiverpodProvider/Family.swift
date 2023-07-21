import Foundation
import Combine
import SwiftUI
import IdentifiedCollections

public class Family<T> {
  private var items = IdentifiedArrayOf<Provider<T>>()
  
  public init() {
    
  }
  
  @discardableResult
  public func append(value: () -> T) -> UUID {
    let node = Provider<T> { value() }
    items[id: node.id] = node
    return node.id
  }
  
  @discardableResult
  public func remove(_ id: UUID?) -> Provider<T>? {
    if let id {
      return items.remove(id: id)
    }
    return nil
  }
  
  @discardableResult
  public func value(_ id: UUID?) -> Provider<T>? {
    if let id {
      return items[id: id]
    }
    return nil
  }
}

public class MutableSelector<T> {
  let selector: Selector<T>
  let update: (T) -> ()
  
  init(selector: Selector<T>, update: @escaping (T) -> ()) {
    self.selector = selector
    self.update = update
  }
}

extension Selector {
  public func update(update: @escaping (T) -> ()) -> MutableSelector<T> {
    MutableSelector(selector: self, update: update)
  }
}

@propertyWrapper
public struct MutableValue<T>: DynamicProperty {
  @ObservedObject private var source: Source<T>
  private var sink: (T) -> ()
  
  public init(_ node: Provider<T>) {
    self.source = Source(node: node)
    self.sink = { node.value = $0 }
  }
  
  public init(_ mutableSelector: MutableSelector<T>) {
    self.source = Source(selector: mutableSelector.selector)
    self.sink = mutableSelector.update
  }
  
  public var wrappedValue: T {
    get { source.value }
    nonmutating set {
      sink(newValue)
    }
  }
  
  public var projectedValue: Binding<T> {
    Binding(
      get: { self.wrappedValue },
      set: sink
    )
  }
}


public class Selector<T>: ObservableObject {
  public let objectWillChange = ObservableObjectPublisher()
  private let getValue: () -> T
  
  var value: T { getValue() }
  
  public init(get: @escaping (Getter) -> T) {
    let getter = Getter(sink: objectWillChange.send)
    
    getValue = {
      getter.dependecies = [:]
      return get(getter)
    }
  }
}

public class Getter {
  private let sink: () -> ()
  fileprivate var dependecies = [UUID: AnyCancellable]()
  
  init(sink: @escaping () -> ()) {
    self.sink = sink
  }
  
  public func callAsFunction<T>(_ atom: Provider<T>) -> T {
    dependecies[atom.id] = atom.objectWillChange.sink {
      self.sink()
    }
    
    return atom.value
  }
}


class Source<T>: ObservableObject {
  let objectWillChange: ObservableObjectPublisher
  var valueProvider: () -> T
  
  var value: T { valueProvider() }
  
  public init(node: Provider<T>) {
    self.objectWillChange = node.objectWillChange
    self.valueProvider = { node.value }
  }
  
  init(selector: Selector<T>) {
    self.objectWillChange = selector.objectWillChange
    self.valueProvider = { selector.value }
  }
}

@propertyWrapper
public struct Value<T>: DynamicProperty {
  @ObservedObject private var source: Source<T>
  
  public init(_ selector: Selector<T>) {
    self.source = Source(selector: selector)
  }
  
  public init(_ node: Provider<T>) {
    self.source = Source(node: node)
  }
  
  public var wrappedValue: T {
    get { source.value }
  }
}
