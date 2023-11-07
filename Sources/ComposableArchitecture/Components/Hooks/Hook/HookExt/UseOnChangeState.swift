import SwiftUI

public func useOnChangeState<Node>(
  _ initialNode: @escaping () -> Node
) -> HState<Node> {
  useOnChangeState(initialNode())
}

public func useOnChangeState<Node>(
  _ initialNode: Node
) -> HState<Node> {
  HState(wrappedValue: initialNode)
}
