import Foundation

@propertyWrapper
@MainActor public struct RecoilContext {
  
  private let location: SourceLocation
  
  public init(
    fileID: String = #fileID,
    line: UInt = #line
  ) {
    location = SourceLocation(fileID: fileID, line: line)
  }
  
  public var wrappedValue: RecoilGlobalContext {
    RecoilGlobalViewContext(location: location).wrappedValue
  }
  
  public var projectedValue: Self {
    self
  }
}
