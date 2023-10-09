import SwiftUI

extension View {
  public func logChanges(
    fileID: String = #fileID,
    line: UInt = #line,
    _ data: Any? = nil
  ) -> some View {
    print("⚠️ Re-Render in: \(SourceLocation(fileID: fileID, line: line))")
    if let data {
      print(data)
    }
    return EmptyView()
      .hidden()
  }
}

public struct LogChangesView: View {
  
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
    if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
      Self._printChanges()
    } else {
      print("⚠️ Re-Render in: \(SourceLocation(fileID: fileID, line: line))")
    }
    if let data {
      print(data)
    }
    return Color.white.opacity(0.001)
      .frame(height: 0.001)
      .hidden()
  }
  
}

extension View {
  
  /// A helper function that returns a platform-specific value.
  public func valueFor<V>(iOS: V, tvOS: V, visionOS: V) -> V {
#if os(xrOS)
    visionOS
#elseif os(tvOS)
    tvOS
#else
    iOS
#endif
  }
  
  /// A Boolean value that indicates whether the current platform is visionOS.
  ///
  /// If the value is `true`, `isMobile` is also true.
  public var isVision: Bool {
#if os(xrOS)
    true
#else
    false
#endif
  }
  
  /// A Boolean value that indicates whether the current platform is iOS or iPadOS.
  public var isMobile: Bool {
#if os(iOS)
    true
#else
    false
#endif
  }
  
  /// A Boolean value that indicates whether the current platform is tvOS.
  public var isTV: Bool {
#if os(tvOS)
    true
#else
    false
#endif
  }
  
  /// A debugging function to add a border around a view.
  public func debugBorder(color: Color = .red, width: CGFloat = 1.0, opacity: CGFloat = 1.0) -> some View {
    self
#if DEBUG
      .border(color, width: width)
      .opacity(opacity)
#endif
  }
}

