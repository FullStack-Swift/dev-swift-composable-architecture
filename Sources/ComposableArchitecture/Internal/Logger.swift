import Foundation

private enum LogLevel: String {
  case info       = "🔵"
  case debug      = "🟡"
  case warning    = "🟠"
  case error      = "🔴"
}

#if canImport(os)
import os
public let log = Logger()

public extension Logger {
  private var isLogEnable: Bool {
#if DEBUG
    return true
#else
    return false
#endif
  }
  
  private func sourceFileName(filePath: String) -> String {
    let components = filePath.components(separatedBy: "/")
    if let componentLast = components.last {
      return componentLast
    } else {
      return ""
    }
  }
  
  func error(
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
  
  func warning(
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
  
  func debug(
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
  
  func info(
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
  
  func json(
    filename: String = #file,
    line: Int = #line,
    funcName: String = #function,
    _ object: Any
  ) {
    if isLogEnable {
      print("💎 JSON [[\(sourceFileName(filePath: filename))]:\(line) \(funcName)]")
      if JSONSerialization.isValidJSONObject(object), let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]) {
        print(Json(data))
        return
      } else {
        print(Json(object))
        return
      }
    }
  }
}
#else

private func print(_ object: Any) {
#if DEBUG
  Swift.print(object)
#endif
}
internal typealias log = FLogger

internal final class FLogger {
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

internal extension FLogger {
  
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
#endif
