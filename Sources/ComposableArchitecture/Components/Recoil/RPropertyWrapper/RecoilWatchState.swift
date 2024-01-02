import Foundation
import SwiftUI

@propertyWrapper
@MainActor public struct RecoilWatchState<Node: StateAtom> {
  
  let ref: RecoilHookRef<Node>
  
  private let updateStrategy: HookUpdateStrategy
  
  public init(
    _ node: Node,
    updateStrategy: HookUpdateStrategy = .once,
    fileID: String = #fileID,
    line: UInt = #line
  ) {
    self.updateStrategy = updateStrategy
    ref = RecoilHookRef(location: SourceLocation(fileID: fileID, line: line), initialNode: node)
  }
  
  public var wrappedValue: Node.Loader.Value {
    get { ref.context.watch(ref.node) }
    nonmutating set {ref.context.set(newValue, for: ref.node)}
  }
  
  public var projectedValue: Binding<Node.Loader.Value> {
    ref.context.binding(ref.node)
  }
}

extension RecoilWatchState {
  public var context: RecoilGlobalContext {
    ref.context
  }
}

extension RecoilWatchState where Node.Loader: RefreshableAtomLoader {
  func refresh() async -> Node.Loader.Value {
    await context.refresh(ref.node)
  }
}
