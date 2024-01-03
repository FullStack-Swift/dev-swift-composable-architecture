#if canImport(SwiftCompilerPlugin)
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MyPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    StringifyMacro.self,
    URLMacro.self,
    AddAsyncMacro.self,
    WarningMacro.self,
    TodoMacro.self,
    AttachedMacroEnvironmentKey.self,
    AttachedMacroDependencyKey.self,
    EnvironmentStorage.self,
    AssociatedObjectMacro.self,
//    ObservableMacro.self,
//    ObservationTrackedMacro.self,
//    ObservationIgnoredMacro.self,
  ]
}
#endif
