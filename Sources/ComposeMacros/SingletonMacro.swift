import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct Singleton: MemberMacro {
  public static func expansion(
    of node: SwiftSyntax.AttributeSyntax,
    providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
    in context: some SwiftSyntaxMacros.MacroExpansionContext
  ) throws -> [SwiftSyntax.DeclSyntax] {
    guard [SwiftSyntax.SyntaxKind.classDecl, SwiftSyntax.SyntaxKind.structDecl].contains(declaration.kind) else {
      throw MacroError.message("Can only be applied ti a struct or class")
    }
    let identifier = (declaration as? StructDeclSyntax)?.name ?? (declaration as? ClassDeclSyntax)?.name ?? ""
    var overrride = ""
    return []
  }
}
