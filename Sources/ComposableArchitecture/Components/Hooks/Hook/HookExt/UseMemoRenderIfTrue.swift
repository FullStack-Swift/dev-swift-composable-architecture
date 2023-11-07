import Foundation

public func useMemoRenderIfTrue<Node>(
  _ condition: Bool? = false,
  _ initialNode: @escaping () -> Node
) -> Node {
  let flag = useFlagUpdated(condition)
  return useMemo(.preserved(by: flag)) {
    initialNode()
  }
}
