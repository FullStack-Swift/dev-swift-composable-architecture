import Foundation

public extension TimeInterval {
  var toseconds: TimeInterval {
    self * 1_000_000_000
  }
}
