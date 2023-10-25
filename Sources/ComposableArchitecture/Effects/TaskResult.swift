import XCTestDynamicOverlay

enum TaskResultDebugging {
  @TaskLocal static var emitRuntimeWarnings = true
}

extension TaskResult: Equatable where Success: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
      case let (.success(lhs), .success(rhs)):
        return lhs == rhs
      case let (.failure(lhs), .failure(rhs)):
        return _isEqual(lhs, rhs)
        ?? {
#if DEBUG
          let lhsType = type(of: lhs)
          if TaskResultDebugging.emitRuntimeWarnings, lhsType == type(of: rhs) {
            let lhsTypeName = typeName(lhsType)
            runtimeWarn(
                """
                "\(lhsTypeName)" is not equatable. …
                
                To test two values of this type, it must conform to the "Equatable" protocol. For \
                example:
                
                    extension \(lhsTypeName): Equatable {}
                
                See the documentation of "TaskResult" for more information.
                """
            )
          }
#endif
          return false
        }()
      default:
        return false
    }
  }
}

extension TaskResult: Hashable where Success: Hashable {
  public func hash(into hasher: inout Hasher) {
    switch self {
      case let .success(value):
        hasher.combine(value)
        hasher.combine(0)
      case let .failure(error):
        if let error = (error as Any) as? AnyHashable {
          hasher.combine(error)
          hasher.combine(1)
        } else {
#if DEBUG
          if TaskResultDebugging.emitRuntimeWarnings {
            let errorType = typeName(type(of: error))
            runtimeWarn(
              """
              "\(errorType)" is not hashable. …
              
              To hash a value of this type, it must conform to the "Hashable" protocol. For example:
              
                  extension \(errorType): Hashable {}
              
              See the documentation of "TaskResult" for more information.
              """
            )
          }
#endif
        }
    }
  }
}

extension TaskResult {
  // NB: For those that try to interface with `TaskResult` using `Result`'s old API.
  @available(*, unavailable, renamed: "value")
  public func get() throws -> Success {
    try self.value
  }
}
