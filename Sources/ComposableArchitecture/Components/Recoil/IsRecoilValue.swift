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
