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
    EnvironmentStorage.self,
  ]
}
#endif
