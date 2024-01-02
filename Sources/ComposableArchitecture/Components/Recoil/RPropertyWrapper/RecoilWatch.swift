import Foundation
import SwiftUI

@propertyWrapper
@MainActor public struct RecoilWatch<Node: Atom> {
  
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
    useRecoilWatch(updateStrategy: updateStrategy, ref.node)
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
    wrappedValue
  }
}

extension RecoilWatch where Node: StateAtom {
  
  public var state: Binding<Node.Loader.Value> {
    context.state(ref.node)
  }
}

extension RecoilWatch where Node.Loader: RefreshableAtomLoader {
  func refresh() async -> Node.Loader.Value {
    await context.refresh(ref.node)
  }
}
