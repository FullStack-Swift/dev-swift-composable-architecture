import IdentifiedCollections

public extension IdentifiedArray where Element: Identifiable {
  init(@ArrayBuilder<Element> builder: () -> [Element]) where ID == Element.ID {
    var identifiedArray: IdentifiedArrayOf<Element> = []
    identifiedArray.updateOrAppend(builder())
    self = identifiedArray
  }
}

public extension Array where Element: Identifiable {
  func toIdentifiedArray() -> IdentifiedArrayOf<Element> {
    var identifiedArray: IdentifiedArrayOf<Element> = []
    for value in self {
      identifiedArray.updateOrAppend(value)
    }
    return identifiedArray
  }
}

public extension IdentifiedArray {
  func toArray() -> [Element] {
    var array: [Element] = []
    for value in self {
      array.append(value)
    }
    return array
  }
}

public extension IdentifiedArray where Element: Identifiable {
  
  @discardableResult
  mutating func updateOrAppend(_ other: Self) -> Self {
    for item in other {
      self.updateOrAppend(item)
    }
    return self
  }
  
  @discardableResult
  mutating func updateOrAppend(_ other: [Element]) -> Self {
    for item in other {
      self.updateOrAppend(item)
    }
    return self
  }
  
  @discardableResult
  mutating func updateOrAppend(ifLet item: Element?) -> Self {
    guard let item = item else {
      return self
    }
    self.updateOrAppend(item)
    return self
  }
}
