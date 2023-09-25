import Foundation

// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.
@freestanding(expression) 
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "ComposeMacros", type: "StringifyMacro")

/// A macro that produces an async funtion from a completion function.
///
@attached(peer, names: overloaded)
public macro AddAsync() = #externalMacro(module: "ComposeMacros", type: "AddAsyncMacro")


/// A macro that produces an unwrapped URL in case of a valid input URL.
/// For example,
///
///     #URL("https://www.avanderlee.com")
///
/// produces an unwrapped `URL` if the URL is valid. Otherwise, it emits a compile-time error.
@freestanding(expression)
public macro URL(_ stringLiteral: String) -> URL = #externalMacro(module: "ComposeMacros", type: "URLMacro")

/// Macro that produces a warning, as a replacement for the built-in
/// #warning("...").
@freestanding(expression) public macro mWarning(_ message: String) = #externalMacro(module: "ComposeMacros", type: "WarningMacro")

/// Macro that produces a todo.
@freestanding(expression) public macro mTodo(_ message: String) = #externalMacro(module: "ComposeMacros", type: "TodoMacro")

@attached(peer, names: arbitrary)
public macro Renamed(from previousName: String) = #externalMacro(module: "ComposeMacros", type: "RenameMacro")

/// Creates an unique EnvironmentKey for the variable and adds getters and setters.
/// The initial value of the variable becomes the default value of the EnvironmentKey.
@attached(peer, names: prefixed(EnvironmentKey_))
@attached(accessor, names: named(get), named(set))
public macro EnvironmentValue() = #externalMacro(module: "ComposeMacros", type: "AttachedMacroEnvironmentKey")

/// Applies the @EnvironmentValue macro to each child in the scope.
/// This should only be applied on an EnvironmentValues extension.
@attached(memberAttribute)
public macro EnvironmentStorage() = #externalMacro(module: "ComposeMacros", type: "EnvironmentStorage")
