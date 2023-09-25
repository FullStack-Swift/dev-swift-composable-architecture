import Foundation

/// Utilty for applying a transform to a value.
/// - Parameters:
///   - transform: The transform to apply.
///   - input: The value to be transformed.
/// - Returns: The transformed value.
public func apply<T>(_ transform: (inout T) -> Void, to input: T) -> T {
  var transformed = input
  transform(&transformed)
  return transformed
}

/// return description sourceId
/// - Parameters:
///   - id: id description
///   - fileID: fileID description
///   - line: line description
/// - Returns: description
public func sourceId(
  id: String = "",
  fileID: String = #fileID,
  line: UInt = #line
) -> String {
  if id.isEmpty {
    return "fileID: \(fileID) line: \(line)"
  } else {
    return "fileID: \(fileID) line: \(line) id: \(id)"
  }
}
