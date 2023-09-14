#if canImport(UIKit) && !os(watchOS)
import UIKit
import SwiftUI

public struct UIViewRepresented<UIViewType>: UIViewRepresentable where UIViewType: UIView {
  public let makeUIView: (Context) -> UIViewType
  public let updateUIView: (UIViewType, Context) -> Void = { _, _ in }
  
  public init(makeUIView: @escaping (Context) -> UIViewType) {
    self.makeUIView = makeUIView
  }
  
  public func makeUIView(context: Context) -> UIViewType {
    self.makeUIView(context)
  }
  
  public func updateUIView(_ uiView: UIViewType, context: Context) {
    self.updateUIView(uiView, context)
  }
}

extension UIViewController {
  public func toSwiftUI() -> some View {
    UIViewRepresented(makeUIView: { _ in self.view })
  }
}
#endif
