import Foundation

#if canImport(UIKit) && !os(watchOS)
import UIKit
import UniformTypeIdentifiers

public func copyToClipboard(text: String) {
  UIPasteboard.general.setValue(
    text,
    forPasteboardType: UTType.plainText.identifier
  )
}
#endif
