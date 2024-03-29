import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct AttachedMacroStorageKey: PeerMacro {
  
  public static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    
    // Skip declarations other than variables
    guard let varDecl = declaration.as(VariableDeclSyntax.self) else {
      return []
    }
    
    guard var binding = varDecl.bindings.first else {
      context.diagnose(
        Diagnostic(
          node: Syntax(node),
          message: CoreDiagnosticMessage(
            message: "",
            diagnosticID: MessageID(domain: "", id: ""),
            severity: .error
          )
        )
      )
      return []
    }
    
    guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
      context.diagnose(
        Diagnostic(node: Syntax(node),
                   message: CoreDiagnosticMessage(
                    message: "",
                    diagnosticID: MessageID(domain: "", id: ""),
                    severity: .error)
                  )
      )
      return []
    }
    
    binding.pattern = PatternSyntax(IdentifierPatternSyntax(identifier: .identifier("defaultValue")))
    
    let isOptionalType = binding.typeAnnotation?.type.is(OptionalTypeSyntax.self) ?? false
    let hasDefaultValue = binding.initializer != nil
    
    guard isOptionalType || hasDefaultValue else {
      context.diagnose(
        Diagnostic(
          node: Syntax(node),
          message: CoreDiagnosticMessage(
            message: "",
            diagnosticID: MessageID(domain: "", id: ""),
            severity: .error
          )
        )
      )
      return []
    }
    
    return [
            """
            internal struct StorageKey_\(raw: identifier): StorageKey {
                var \(binding)
            }
            """
    ]
  }
}

extension AttachedMacroStorageKey: AccessorMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingAccessorsOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [AccessorDeclSyntax] {
    
    // Skip declarations other than variables
    guard let varDecl = declaration.as(VariableDeclSyntax.self) else {
      return []
    }
    
    guard let binding = varDecl.bindings.first else {
      context.diagnose(
        Diagnostic(
          node: Syntax(node),
          message: CoreDiagnosticMessage(
            message: "",
            diagnosticID: MessageID(domain: "", id: ""),
            severity: .error
          )
        )
      )
      return []
    }
    
    guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
      context.diagnose(
        Diagnostic(
          node: Syntax(node),
          message: CoreDiagnosticMessage(
            message: "",
            diagnosticID: MessageID(domain: "", id: ""),
            severity: .error
          )
        )
      )
      return []
    }
    
    return [
            """
            get {
                self[StorageKey\(raw: identifier).self] ?? StorageKey_\(raw: identifier)()
            }
            """,
            """
            set {
                self.storage[StorageKey\(raw: identifier).self] = newValue
            }
            """
    ]
  }
}
