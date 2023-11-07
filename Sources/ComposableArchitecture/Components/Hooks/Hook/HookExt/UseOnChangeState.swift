import SwiftUI

public func useOnChangeState<Node>(
  _ initialNode: @escaping () -> Node,
  onChange: @escaping (Node) -> Void
) -> Binding<Node> {
  useOnChangeState(initialNode(), onChange: onChange)
}

public func useOnChangeState<Node>(
  _ initialNode: Node,
  onChange: @escaping (Node) -> Void
) -> Binding<Node> {
  let state = HState(wrappedValue: initialNode)
    .onChange(onChange)
  return state.projectedValue
}
