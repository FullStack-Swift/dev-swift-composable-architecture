import Foundation

@resultBuilder
public struct JsonResultBuilder {
  public static func buildBlock() -> Json {
    DictionaryJson {
      
    }.json
  }
  
  public static func buildBlock(_ json: ConvertJsonProtocol) -> Json {
    return json.json
  }
  
  public static func buildArray(_ components: [ConvertJsonProtocol]) -> Json {
    if components.isEmpty {
      return Json()
    }
    if components.count == 1 {
      return components.first!.json
    }
    let json = components[0].json.merge(with: components[1].json)
    for index in 2...components.count-1 {
      json.merge(with: components[index].json)
    }
    return json
  }
  
  public static func buildBlock(_ components: ConvertJsonProtocol...) -> Json {
    return buildArray(components)
  }
}

public protocol ConvertJsonProtocol {
  var json: Json { get }
}

public class ArrayItemBuilder {
  var value: Any
  
  init(_ value: Any) {
    self.value = value
  }
  
}

@resultBuilder
public struct ArrayResultBuilder {
  public static func buildBlock<Content>(_ components: Content...) -> [Content] where Content: ArrayItemBuilder {
    return components
  }
}

public struct ArrayJson: ConvertJsonProtocol {
  var arrayItemBuilder: [ArrayItemBuilder]
  
  public init(@ArrayResultBuilder builder: @escaping  (() -> [ArrayItemBuilder])) {
    self.arrayItemBuilder = builder()
  }
  
  public var json: Json {
    Json(arrayItemBuilder.map {$0.value})
  }
}

extension ArrayJson: Equatable {
  public static func == (lhs: ArrayJson, rhs: ArrayJson) -> Bool {
    return lhs.json == rhs.json
  }
}

public class DictionaryItemBuilder {
  var key: String
  var value: Any
  
  init(key: String, value: Any) {
    self.key = key
    self.value = value
  }
}

@resultBuilder
public struct DictionaryResultBuilder {
  public static func buildBlock<Content>(_ components: Content...) -> [Content] where Content: DictionaryItemBuilder {
    return components
  }
}

public struct DictionaryJson: ConvertJsonProtocol {
  var dictionariesItemBuilder: [DictionaryItemBuilder]
  
  public init(@DictionaryResultBuilder builder: @escaping  (() -> [DictionaryItemBuilder])) {
    self.dictionariesItemBuilder = builder()
  }
  
  public var json: Json {
    var dict: [String: Any] = [:]
    for item in dictionariesItemBuilder {
      dict[item.key] = item.value
    }
    return Json(dict)
  }
}

extension DictionaryJson: Equatable {
  public static func == (lhs: DictionaryJson, rhs: DictionaryJson) -> Bool {
    return lhs.json == rhs.json
  }
}
