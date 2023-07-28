import SwiftUI

extension View {
  public func logRenderUI(
    fileID: String = #fileID,
    line: UInt = #line,
    _ data: Any? = nil
  ) -> some View {
    print("⚠️ Re-Render in: \(SourceLocation(fileID: fileID, line: line))")
    print(data ?? "Null")
    return EmptyView()
      .hidden()
  }
}

public struct LogRerenderView: View {
  
  let fileID: String
  let line: UInt
  var data: Any? = nil
  
  public init(
    fileID: String = #fileID,
    line: UInt = #line,
    _ data: Any? = nil
  ) {
    self.fileID = fileID
    self.line = line
    self.data = data
  }
  
  public var body: some View {
    print("⚠️ Re-Render in: \(SourceLocation(fileID: fileID, line: line))")
    print(data ?? "Null")
    return EmptyView()
      .hidden()
  }
  
}
