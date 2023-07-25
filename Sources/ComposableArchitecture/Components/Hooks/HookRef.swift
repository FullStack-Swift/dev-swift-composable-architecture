import Foundation

internal class HookRef<Node> {
  
  internal var node: Node
  
  internal var task: Task<Void, Never>? {
    didSet {
      oldValue?.cancel()
    }
  }
  
  internal var isDisposed = false
  
  internal var cancellables: SetCancellables = []
  
  internal init(_ initialNode: Node) {
    node = initialNode
  }
  
  internal func dispose() {
    task = nil
    cancellables.dispose()
    isDisposed = true
  }
}
