import Combine

public protocol NotifierBase {
  associatedtype State
  
  func build() -> State
}

@dynamicMemberLookup
open class Notifier<State>: NotifierBase {
  
 
  @MStateSubject<State?>
  public var stateSubject = nil
  
  public var observable: ObservableListener = ObservableListener()
  
  public init() {
    self.stateSubject = build()
  }
  
  open func build() -> State {
    fatalError("implementd")
  }
  
  public subscript<Value>(
    dynamicMember keyPath: WritableKeyPath<State, Value>
  ) -> Value {
    get {
      self.state[keyPath: keyPath]
    }
    set {
      self.state[keyPath: keyPath] = newValue
    }
  }
  
  open var value: State {
    get {
      state
    }
    set {
      state = newValue
    }
  }
  
  open var state: State {
    get {
      stateSubject ?? build()
    }
    
    set {
      stateSubject = newValue
      observable.send()
    }
  }
}


@propertyWrapper
public struct MStateSubject<Node> {
  
  public var stateSubject: CurrentValueSubject<Node, Never>
  
  public init(wrappedValue: Node) {
    self.stateSubject = CurrentValueSubject(wrappedValue)
  }
  
  public var wrappedValue: Node {
    get {
      stateSubject.value
    }
    
    set {
      stateSubject.value = newValue
    }
  }
  
  public var projectedValue: CurrentValueSubject<Node, Never> {
    stateSubject
  }
  
  public func commit(_ block: (inout Node) -> Void) {
    stateSubject.commit(block)
  }
}
