import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import Foundation

public struct AddAsyncMacro: PeerMacro {
  
  public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
    guard let functionDecl = declaration.as(FunctionDeclSyntax.self) else {
      throw MacroError.message("@AddAsync can be attached only to functions.")
    }
    
    let signature = functionDecl.signature
    let parameters = signature.parameterClause.parameters
    if let completion = parameters.last, let completionType = completion.type.as(FunctionTypeSyntax.self)?.parameters.first {
      let remainPara = FunctionParameterListSyntax(parameters.dropLast())
      let functionArgs = remainPara.map { parameter -> String in
        guard let paraType = parameter.type.as(IdentifierTypeSyntax.self)?.name else { return "" }
        return "\(parameter.firstName): \(paraType)"
      }.joined(separator: ", ")
      
      let calledArgs = remainPara.map { "\($0.firstName): \($0.firstName)" }.joined(separator: ", ")
      return [
          """
          func \(functionDecl.name)(\(raw: functionArgs)) async -> \(completionType) {
            await withCheckedContinuation { continuation in
              self.\(functionDecl.name)(\(raw: calledArgs)) { object in
                continuation.resume(returning: object)
              }
            }
          }
          """
      ]
    }
    return []
  }
}
