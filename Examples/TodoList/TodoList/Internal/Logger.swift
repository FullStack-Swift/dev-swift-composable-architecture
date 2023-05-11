import Foundation

private enum LogLevel: String {
  case info       = "🔵"
  case debug      = "🟡"
  case warning    = "🟠"
  case error      = "🔴"
}

private func print(_ object: Any) {
#if DEBUG
  Swift.print(object)
#endif
}

public typealias log = Logger

public final class Logger {
  private static var isLogEnable: Bool {
#if DEBUG
    return true
#else
    return false
#endif
  }

  private class func sourceFileName(filePath: String) -> String {
    let components = filePath.components(separatedBy: "/")
    if let componentLast = components.last {
      return componentLast
    } else {
      return ""
    }
  }
}

public extension Logger {

  class func error(
    filename: String = #file,
    line: Int = #line,
    funcName: String = #function,
    _ object: Any
  ) {
    if isLogEnable {
      print("\(LogLevel.error.rawValue) ERROR [[\(sourceFileName(filePath: filename))]:\(line) \(funcName)]")
      print(object)
    }
  }

  class func warning(
    filename: String = #file,
    line: Int = #line,
    funcName: String = #function,
    _ object: Any
  ) {
    if isLogEnable {
      print("\(LogLevel.warning.rawValue) WARNING [[\(sourceFileName(filePath: filename))]:\(line) \(funcName)]")
      print(object)
    }
  }

  class func debug(
    filename: String = #file,
    line: Int = #line,
    funcName: String = #function,
    _ object: Any
  ) {
    if isLogEnable {
      print("\(LogLevel.debug.rawValue) DEBUG [[\(sourceFileName(filePath: filename))]:\(line) \(funcName)]")
      print(object)
    }
  }

  class func info(
    filename: String = #file,
    line: Int = #line,
    funcName: String = #function,
    _ object: Any
  ) {
    if isLogEnable {
      print("\(LogLevel.info.rawValue) INFO [[\(sourceFileName(filePath: filename))]:\(line) \(funcName)]")
      print(object)
    }
  }
}
