import Foundation

public func isRecoilType<T>(type: T) -> Bool {
  if type is (any Atom) {
    return true
  }
  return false
}


public func isRecoilValue<V>(type: V) -> Bool {
  if type is (any ValueAtom) {
    return true
  }
  return false
}

public func isRecoilState<T>(type: T) -> Bool {
  if type is (any StateAtom) {
    return true
  }
  return false
}

public func isRecoilPublisher<T>(type: T) -> Bool {
  if type is (any PublisherAtom) {
    return true
  }
  return false
}

public func isRecoilTask<T>(type: T) -> Bool {
  if type is (any TaskAtom) {
    return true
  }
  return false
}

public func isRecoilThrowingTask<T>(type: T) -> Bool {
  if type is (any ThrowingTaskAtom) {
    return true
  }
  return false
}
