import Foundation

enum MacroError: Error, CustomStringConvertible {
  case message(String)
  
  var description: String {
    switch self {
      case .message(let text):
        return text
    }
  }
}

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

struct CoreDiagnosticMessage: DiagnosticMessage, Error {
  let message: String
  let diagnosticID: MessageID
  let severity: DiagnosticSeverity
}
