import Foundation

public enum JsonKey {
  case index(Int)
  case key(String)
}

public protocol JsonSubscriptType {
  var jsonKey: JsonKey { get }
}

extension Int: JsonSubscriptType {
  public var jsonKey: JsonKey {
    return JsonKey.index(self)
  }
}

extension String: JsonSubscriptType {
  public var jsonKey: JsonKey {
    return JsonKey.key(self)
  }
}
