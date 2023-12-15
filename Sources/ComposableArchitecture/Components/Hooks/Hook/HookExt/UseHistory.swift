

@discardableResult
public func useHistory<Node>() -> Array<Node> {
  @HRef var history = [Node]()
  return history
}
