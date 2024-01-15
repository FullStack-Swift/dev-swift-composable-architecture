import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacrosPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    ReducerMacro.self,
    ValueAtomMacro.self,
    StateAtomMacro.self,
    TaskAtomMacro.self,
    ThrowingTaskAtomMacro.self,
    PublisherAtomMacro.self,
    ObservableObjectAtomMacro.self,
    AsyncSequenceAtomMacro.self,
  ]
}
