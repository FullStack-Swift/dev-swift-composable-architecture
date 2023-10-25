import Foundation

public struct MBackport<Content> {
  public let content: Content
  
  public init(_ content: Content) {
    self.content = content
  }
}
