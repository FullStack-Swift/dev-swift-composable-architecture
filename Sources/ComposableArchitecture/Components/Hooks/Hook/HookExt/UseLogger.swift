import Foundation

/// Debug lifecycle events with useLogger.
/// DESCRIPTION:
/// The useLogger hook is useful for logging various lifecycle events in a React component. This custom hook accepts a name parameter and additional arguments, and it logs the lifecycle events (mounted, updated, and unmounted) along with the provided name and arguments. This useLogger hook can be employed to facilitate debugging, monitoring, or performance optimization by providing insights into when and how a component’s lifecycle events occur.
///
/// - Parameters:
///   - name: The name or identifier for the logger.
///   - items: Zero or more items to print.
///   - separator: A string to print between each item. The default is a single
///     space (`" "`).
///   - terminator: The string to print after all items have been printed. The
///     default is a newline (`"\n"`).
public func useLogger(
  fileID: String = #fileID,
  line: UInt = #line,
  _ updateStrategy: HookUpdateStrategy? = .once,
  name: String = "",
  _ items: Any...,
  separator: String = " ",
  terminator: String = "\n"
) {
  useHook(
    LoggerHook(
      updateStrategy: updateStrategy,
      location: SourceLocation(fileID: fileID, line: line),
      name: name,
      items: items,
      separator: separator,
      terminator: terminator
    )
  )
}

/// Debug lifecycle events with useLogger.
/// DESCRIPTION:
/// The useLogger hook is useful for logging various lifecycle events in a React component. This custom hook accepts a name parameter and additional arguments, and it logs the lifecycle events (mounted, updated, and unmounted) along with the provided name and arguments. This useLogger hook can be employed to facilitate debugging, monitoring, or performance optimization by providing insights into when and how a component’s lifecycle events occur.
///
/// - Parameters:
///   - name: The name or identifier for the logger.
///   - items: Zero or more items to print.
///   - separator: A string to print between each item. The default is a single
///     space (`" "`).
///   - terminator: The string to print after all items have been printed. The
///     default is a newline (`"\n"`).
public func useLogger(
  fileID: String = #fileID,
  line: UInt = #line,
  _ updateStrategy: HookUpdateStrategy? = .once,
  name: () -> String,
  _ items: Any...,
  separator: String = " ",
  terminator: String = "\n"
) {
  useHook(
    LoggerHook(
      updateStrategy: updateStrategy,
      location: SourceLocation(fileID: fileID, line: line),
      name: name(),
      items: items,
      separator: separator,
      terminator: terminator
    )
  )

}

private struct LoggerHook: Hook {
  
  typealias State = _HookRef
  
  let updateStrategy: HookUpdateStrategy?
  let location: SourceLocation
  var name: String = ""
  var items: [Any]
  var separator: String = " "
  var terminator: String = "\n"
  
  func makeState() -> _HookRef {
    State()
  }
  
  func value(coordinator: Coordinator) -> () {
    
  }
  
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
#if DEBUG
    print("⚠️", location.sourceId, name)
    for item in items {
      print(item, separator: separator, terminator: terminator)
    }
#endif
  }
  
}

private extension LoggerHook {
  
  final class _HookRef {
    var isDisposed = false
    
    func dispose() {
      isDisposed = true
    }
  }
  
}

@propertyWrapper
public struct HLogger {
  
  public var wrappedValue: any Equatable
  
  let updateStrategy: HookUpdateStrategy?
  
  public init(
    wrappedValue: any Equatable,
    fileID: String = #fileID,
    line: UInt = #line,
    _ updateStrategy: HookUpdateStrategy? = nil,
    name: String = "",
    separator: String = " ",
    terminator: String = "\n"
  ) {
    self.wrappedValue = wrappedValue
    self.updateStrategy = updateStrategy
    useLogger(
      fileID: fileID,
      line: line,
      updateStrategy,
      name: name,
      wrappedValue,
      separator: separator,
      terminator: terminator
    )
  }
}
