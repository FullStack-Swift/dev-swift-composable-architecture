public struct SourceLocation: Codable, Equatable {
  public let fileID: String
  public let line: UInt
  
  public init(fileID: String = #fileID, line: UInt = #line) {
    self.fileID = fileID
    self.line = line
  }
}