import Foundation

private enum LogLevel: String {
  case info       = "🔵"
  case debug      = "🟡"
  case warning    = "🟠"
  case error      = "🔴"
}

#if canImport(OSLog)
import OSLog
public let log = Logger()

public final class Logger {
  public static let shared = Logger()
  public var isEnabled = false
  @Published public var logs: [String] = []
#if DEBUG
  @available(iOS 14, macOS 11, tvOS 14, watchOS 7, *)
  var logger: os.Logger {
    os.Logger(subsystem: "composable-architecture", category: "store-events")
  }
  public func log(level: OSLogType = .default, _ string: @autoclosure () -> String) {
    guard self.isEnabled else { return }
    let string = string()
    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
      print("\(string)")
    } else {
      if #available(iOS 14, macOS 11, tvOS 14, watchOS 7, *) {
        self.logger.log(level: level, "\(string)")
      }
    }
    self.logs.append(string)
  }
  public func clear() {
    self.logs = []
  }
#else
  @inlinable @inline(__always)
  public func log(level: OSLogType = .default, _ string: @autoclosure () -> String) {
  }
  @inlinable @inline(__always)
  public func clear() {
  }
#endif
}

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
      if let object = object as? String, let dict = object.toDictionary() {
        print(Json(dict))
        return
      }
      if let object = object as? Data, let dict = object.toDictionary() {
        print(Json(dict))
        return
      }
      print(Json(object))
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
