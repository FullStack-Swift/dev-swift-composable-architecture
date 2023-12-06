import Foundation

public func isRecoilType<Node>(type: Node) -> Bool {
 type is (any Atom)
}

public func isRecoilValue<Node>(type: Node) -> Bool {
  type is (any ValueAtom)
}

public func isRecoilState<Node>(type: Node) -> Bool {
  type is (any StateAtom)
}

public func isRecoilPublisher<Node>(type: Node) -> Bool {
  type is (any PublisherAtom)
}

public func isRecoilTask<Node>(type: Node) -> Bool {
  type is (any TaskAtom)
}

public func isRecoilThrowingTask<Node>(type: Node) -> Bool {
  type is (any ThrowingTaskAtom)
}

import SwiftUI

@propertyWrapper
@MainActor public struct RecoilWatch<Node: Atom> {
  
  public var wrappedValue: Node
  
  private let updateStrategy: HookUpdateStrategy
  
  let ref: RecoilHookRef<Node>
  
  public init(
    wrappedValue: Node,
    _ updateStrategy: HookUpdateStrategy = .once,
    fileID: String = #fileID,
    line: UInt = #line
  ) {
    self.wrappedValue = wrappedValue
    self.updateStrategy = updateStrategy
    ref = RecoilHookRef(location: SourceLocation(fileID: fileID, line: line), initialNode: wrappedValue)
  }
  
  public var projectedValue: Self {
    self
  }
}

extension RecoilWatch {
  
  public var context: RecoilGlobalContext {
    ref.context
  }
}

extension RecoilWatch {
  
  public var value: Node.Loader.Value {
    useRecoilWatch(updateStrategy: updateStrategy, wrappedValue)
  }
}

extension RecoilWatch where Node: StateAtom {
  
  public var state: Binding<Node.Loader.Value> {
    context.state(wrappedValue)
  }
}

extension RecoilWatch where Node.Loader: RefreshableAtomLoader {
  func refresh() async -> Node.Loader.Value {
    await context.refresh(wrappedValue)
  }
}

@propertyWrapper
@MainActor public struct RecoilRead<Node: Atom> {
  
  public var wrappedValue: Node
  
  private let updateStrategy: HookUpdateStrategy
  
  public init(
    wrappedValue: Node,
    _ updateStrategy: HookUpdateStrategy = .once
  ) {
    self.wrappedValue = wrappedValue
    self.updateStrategy = updateStrategy
  }
  
  public var value: Node.Loader.Value {
    useRecoilReadValue(updateStrategy: updateStrategy, wrappedValue)
  }
  
  public var projectedValue: Self {
    self
  }
}

@propertyWrapper
@MainActor public struct RecoilWatchState<Node: StateAtom> {
  
  public var wrappedValue: Node
  
  internal let _value: Binding<Node.Loader.Value>
  
  private let updateStrategy: HookUpdateStrategy
  
  public init(
    wrappedValue: Node,
    _ updateStrategy: HookUpdateStrategy = .once
  ) {
    self.wrappedValue = wrappedValue
    self.updateStrategy = updateStrategy
    _value = useRecoilState(updateStrategy: updateStrategy, wrappedValue)
  }
  
  public var value: Node.Loader.Value {
    _value.wrappedValue
  }
  
  public var binding: Binding<Node.Loader.Value> {
    _value
  }
  
  public var projectedValue: Self {
    self
  }
}


@propertyWrapper
@MainActor public struct RecoilContext {
  
  private let updateStrategy: HookUpdateStrategy
  
  let context: RecoilGlobalViewContext
  
  public init(
    fileID: String = #fileID,
    line: UInt = #line,
    _ updateStrategy: HookUpdateStrategy = .once
  ) {
    self.updateStrategy = updateStrategy
    self.context = RecoilGlobalViewContext(location: SourceLocation(fileID: fileID, line: line))
  }

  public var wrappedValue: RecoilGlobalContext {
    context.wrappedValue
  }
  
  
  public var projectedValue: Self {
    self
  }
}
