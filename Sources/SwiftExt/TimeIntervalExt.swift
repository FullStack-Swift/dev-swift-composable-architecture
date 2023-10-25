import Foundation

public extension TimeInterval {
  var toNanoseconds: TimeInterval {
    self * 1_000_000_000
  }
}
