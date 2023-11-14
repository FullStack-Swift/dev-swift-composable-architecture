import XCTestDynamicOverlay

enum TaskAsyncPhaseDebugging {
  @TaskLocal static var emitRuntimeWarnings = true
}

extension TaskAsyncPhase: Equatable where Success: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
      case (.pending, .pending):
        return true
      case (.running, .running):
        return true
      case let (.success(lhs), .success(rhs)):
        return lhs == rhs
      case let (.failure(lhs), .failure(rhs)):
        return _isEqual(lhs, rhs)
        ?? {
#if DEBUG
          let lhsType = type(of: lhs)
          if TaskAsyncPhaseDebugging.emitRuntimeWarnings, lhsType == type(of: rhs) {
            let lhsTypeName = typeName(lhsType)
            runtimeWarn(
                """
                "\(lhsTypeName)" is not equatable. …
                
                To test two values of this type, it must conform to the "Equatable" protocol. For \
                example:
                
                    extension \(lhsTypeName): Equatable {}
                
                See the documentation of "TaskAsyncPhase" for more information.
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

extension TaskAsyncPhase: Hashable where Success: Hashable {
  public func hash(into hasher: inout Hasher) {
    switch self {
      case .pending:
        hasher.combine(-2)
      case .running:
        hasher.combine(-1)
      case .success(let value):
        hasher.combine(value)
        hasher.combine(0)
      case .failure(let error):
        if let error = (error as Any) as? AnyHashable {
          hasher.combine(error)
          hasher.combine(0)
        } else {
#if DEBUG
          if TaskAsyncPhaseDebugging.emitRuntimeWarnings {
            let errorType = typeName(type(of: error))
            runtimeWarn(
              """
              "\(errorType)" is not hashable. …
              
              To hash a value of this type, it must conform to the "Hashable" protocol. For example:
              
                  extension \(errorType): Hashable {}
              
              See the documentation of "TaskAsyncPhase" for more information.
              """
            )
          }
#endif
        }
    }
  }
}
