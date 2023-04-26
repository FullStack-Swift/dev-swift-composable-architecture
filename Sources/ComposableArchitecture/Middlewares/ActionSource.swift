public struct ActionSource: Codable, Hashable {
  public let file: String

  public let function: String

  public let line: UInt

  public let info: String?

  public init(file: String, function: String, line: UInt, info: String?) {
    self.file = file
    self.function = function
    self.line = line
    self.info = info
  }
}

extension ActionSource {
  public static func here(file: String = #file, function: String = #function, line: UInt = #line, info: String? = nil) -> ActionSource {
    .init(file: file, function: function, line: line, info: info)
  }
}
