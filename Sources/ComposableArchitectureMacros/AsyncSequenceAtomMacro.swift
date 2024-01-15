import SwiftDiagnostics
import SwiftOperators
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

public enum AsyncSequenceAtomMacro {}

extension AsyncSequenceAtomMacro: ExtensionMacro {
  public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
    if let inheritanceClause = declaration.inheritanceClause, inheritanceClause.inheritedTypes.contains(where: {
      ["AsyncSequenceAtom"].withQualified.contains($0.type.trimmedDescription)
    }) {
      return []
    }
    let ext: DeclSyntax =
    """
    extension \(type.trimmed): ComposableArchitecture.AsyncSequenceAtom {}
    """
    return [ext.cast(ExtensionDeclSyntax.self)]
  }
}

extension AsyncSequenceAtomMacro: MemberAttributeMacro {
  public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingAttributesFor member: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AttributeSyntax] {
    []
  }
}
