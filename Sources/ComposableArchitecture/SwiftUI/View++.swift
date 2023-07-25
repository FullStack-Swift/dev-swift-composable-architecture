import SwiftUI

extension View {
  public func logRenderUI(
    fileID: String = #fileID,
    line: UInt = #line,
    _ data: Any? = nil
  ) -> some View {
    print("⚠️ RefreshUI in: \(SourceLocation(fileID: fileID, line: line))")
    print(data ?? "Null")
    return EmptyView()
      .hidden()
  }
}
