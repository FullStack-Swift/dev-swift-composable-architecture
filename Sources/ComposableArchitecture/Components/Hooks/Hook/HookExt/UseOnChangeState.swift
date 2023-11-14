import SwiftUI

public func useOnChangeState<Node>(
  _ initialNode: @escaping () -> Node
) -> MHState<Node> {
  useOnChangeState(initialNode())
}

public func useOnChangeState<Node>(
  _ initialNode: Node
) -> MHState<Node> {
  MHState(wrappedValue: initialNode)
}
