import Foundation

public extension Array where Element: Equatable {
  var removedDuplicates: [Element] {
    var uniqueValues: [Element] = []
    forEach { item in
      guard !uniqueValues.contains(item) else { return }
      uniqueValues.append(item)
    }
    return uniqueValues
  }
}

public extension Array where Element == [String: Any] {
  
  func toData() -> Data? {
    try? JSONSerialization.data(withJSONObject: self, options: [])
  }
}


public extension Array where Element: Codable {
  
  func toData() -> Data? {
    compactMap({$0.toDictionary()}).toData()
  }
}
