import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

/// Implementation of the `mTodo` macro
public struct TodoMacro: ExpressionMacro {
  public static func expansion(
    of macro: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> ExprSyntax {
    guard let firstElement = macro.arguments.first,
          let stringLiteral = firstElement.expression
      .as(StringLiteralExprSyntax.self),
          stringLiteral.segments.count == 1,
          case let .stringSegment(messageString)? = stringLiteral.segments.first
    else {
      throw MacroError.message("#mTodo macro requires a string literal")
    }
    
    context.diagnose(
      Diagnostic(
        node: Syntax(macro),
        message: SimpleDiagnosticMessage(
          message: messageString.content.description,
          diagnosticID: MessageID(domain: "TODO", id: messageString.content.description),
          severity: .remark
        )
      )
    )
    
    return "()"
  }
}
