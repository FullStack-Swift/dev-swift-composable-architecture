import Foundation

/**
 JSON's type definitions.
 
 See http://www.json.org
 */

public enum TypeJson: Int {
  case number
  case string
  case bool
  case array
  case dictionary
  case null
  case unknown
}

func unwrap(_ object: Any) -> Any {
  switch object {
  case let json as Json:
    return unwrap(json.object)
  case let array as [Any]:
    return array.map(unwrap)
  case let dictionary as [String: Any]:
    var d = dictionary
    dictionary.forEach { pair in
      d[pair.key] = unwrap(pair.value)
    }
    return d
  default:
    return object
  }
}
