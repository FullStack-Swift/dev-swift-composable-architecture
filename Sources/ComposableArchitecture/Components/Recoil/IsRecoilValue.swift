import Foundation

public func isRecoilType<Node>(type: Node) -> Bool {
  if type is (any Atom) {
    return true
  }
  return false
}


public func isRecoilValue<Node>(type: Node) -> Bool {
  if type is (any ValueAtom) {
    return true
  }
  return false
}

public func isRecoilState<Node>(type: Node) -> Bool {
  if type is (any StateAtom) {
    return true
  }
  return false
}

public func isRecoilPublisher<Node>(type: Node) -> Bool {
  if type is (any PublisherAtom) {
    return true
  }
  return false
}

public func isRecoilTask<Node>(type: Node) -> Bool {
  if type is (any TaskAtom) {
    return true
  }
  return false
}

public func isRecoilThrowingTask<Node>(type: Node) -> Bool {
  if type is (any ThrowingTaskAtom) {
    return true
  }
  return false
}
