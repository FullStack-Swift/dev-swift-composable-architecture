import Foundation

@dynamicMemberLookup
public struct Json {
  
  fileprivate var rawArray: [Any] = []
  fileprivate var rawDictionary: [String: Any] = [:]
  fileprivate var rawString: String = ""
  fileprivate var rawNumber: NSNumber = 0
  fileprivate var rawNull: NSNull = NSNull()
  fileprivate var rawBool: Bool = false
  
  public fileprivate(set) var type: TypeJson = .null
  
  public var object: Any {
    get {
      switch type {
        case .array:      return rawArray
        case .dictionary: return rawDictionary
        case .string:     return rawString
        case .number:     return rawNumber
        case .bool:       return rawBool
        default:          return rawNull
      }
    }
    set {
      switch unwrap(newValue) {
        case let number as NSNumber:
          if number.isBool {
            type = .bool
            rawBool = number.boolValue
          } else {
            type = .number
            rawNumber = number
          }
        case let string as String:
          type = .string
          rawString = string
        case _ as NSNull:
          type = .null
        case let array as [Any]:
          type = .array
          rawArray = array
        case let dictionary as [String: Any]:
          type = .dictionary
          rawDictionary = dictionary
        default:
          type = .unknown
      }
    }
  }
  
  public init() {
    object = [String: Any]()
  }
  
  public init(@JsonResultBuilder builder: @escaping (() -> Json)) {
    self = builder()
  }
  
  public init(_ object: Any) {
    switch object {
      case let object as Data:
        self.init(data: object)
      default:
        self.init(jsonObject: object)
    }
  }
  
  public init(model: Encodable) {
    self.init(model.toData() as Any)
  }
  
  public init(data: Data, options: JSONSerialization.ReadingOptions = []) {
    if let object: Any = try? JSONSerialization.jsonObject(with: data, options: options) {
      self.init(jsonObject: object)
    } else {
      self.init(jsonObject: NSNull())
    }
  }
  
  public init(parseJson jsonString: String) {
    if let data = jsonString.toData() {
      self.init(data: data)
    } else {
      self.init(jsonObject: NSNull())
    }
  }
  
  fileprivate init(jsonObject: Any) {
    object = jsonObject
  }
}

extension Json {
  @discardableResult
  public func merge(with other: Json) -> Self {
    var newJson = self
    if type == other.type {
      switch type {
        case .dictionary:
          newJson = Json(newJson.rawDictionary.merge(other.rawDictionary, uniquingKeysWith: { dict1, dict2 in
            dict1
          }))
        case .array:
          newJson = Json(rawArray + other.rawArray)
        default:
          break
      }
    } else {
      if type == .dictionary && other.type == .array {
        newJson = Json((other.object as? [Any])?.appending(value: object) as Any)
      }
      
      if type == .array && other.type == .dictionary {
        newJson = Json((object as? [Any])?.appending(value: other.object) as Any)
      }
    }
    return newJson
  }
}

extension Json {
  static var null: Json {
    return Json(jsonObject: NSNull())
  }
}

extension Json {
  public subscript(_ key: JsonKey) -> Self {
    get {
      var json = Self()
      switch key {
        case .key(let keyString):
          if let dict = self.object as? [String: Any], let value = dict[keyString] {
            json.object = value
          } else {
            return json
          }
        case .index(let indexInt):
          if let array = self.object as? [Any], let value = array[safe: indexInt] {
            json.object = value
          } else {
            return json
          }
      }
      return json
    }
    set {
      switch key {
        case .key(let keyString):
          if var dict = object as? [String: Any] {
            dict[keyString] = newValue
            object = dict
          }
        case .index(let index):
          if var array = self.object as? [Any] {
            array[safe: index] = newValue
            object = array
          }
      }
    }
  }
  
  public subscript(_ key: JsonSubscriptType) -> Self {
    get {
      let key = key.jsonKey
      var json = Self()
      switch key {
        case .key(let keyString):
          if let dict = self.object as? [String: Any], let value = dict[keyString] {
            json.object = value
          } else {
            return json
          }
        case .index(let indexInt):
          if let array = self.object as? [Any], let value = array[safe: indexInt] {
            json.object = value
          } else {
            return json
          }
      }
      return json
    }
    set {
      let key = key.jsonKey
      switch key {
        case .key(let keyString):
          if var dict = object as? [String: Any] {
            dict[keyString] = newValue
            object = dict
          }
        case .index(let index):
          if var array = self.object as? [Any] {
            array[safe: index] = newValue
            object = array
          }
      }
    }
  }
  
  public subscript(_ keys: [JsonKey] = []) -> Self {
    get {
      keys.reduce(self) {$0[$1]}
    }
    set {
      switch keys.count {
        case 0:
          return
        case 1:
          self[keys.first!] = newValue
        default:
          var newKeys = keys
          newKeys.remove(at: 0)
          var json = self[keys.first!]
          json[newKeys] = newValue
          self[keys.first!] = json
          
      }
    }
  }
  
  public subscript(_ keys: [JsonSubscriptType] = []) -> Self {
    get {
      self[keys.map(\.jsonKey)]
    }
    set {
      self[keys.map(\.jsonKey)] = newValue
    }
  }
  
  public subscript(_ keys: JsonKey...) -> Self {
    get {
      self[keys]
    }
    set {
      self[keys] = newValue
    }
  }
  
  public subscript(_ keys: JsonSubscriptType...) -> Self {
    get {
      self[keys.map(\.jsonKey)]
    }
    set {
      self[keys.map(\.jsonKey)] = newValue
    }
  }
  
  public subscript(dynamicMember member: String) -> Self {
    get {
      return self[member.jsonKey]
    }
    set {
      self[member.jsonKey] = newValue
    }
  }
}

extension Json {
  public func downcasting<T>(_ defaultValue: T) -> T {
    downcastingOptional(T.self) ?? defaultValue
  }
  
  public func downcastingOptional<T>(_ type: T.Type) -> T? {
    object as? T
  }
}

extension Json: Equatable {
  public static func == (lhs: Json, rhs: Json) -> Bool {
    if lhs.type == rhs.type {
      switch lhs.type {
        case .string:
          return lhs.rawString == rhs.rawString
        case .number:
          return lhs.rawNumber == rhs.rawNumber
        case .bool:
          return lhs.rawBool == rhs.rawBool
        case .array:
          if lhs.rawArray.count != rhs.rawArray.count {
            return false
          }
          for index in 0..<lhs.rawArray.count-1 {
            if Json(lhs.rawArray[index]) != Json(rhs.rawArray[index]) {
              return false
            }
            return true
          }
        case .dictionary:
          return lhs.rawDictionary == rhs.rawDictionary
        case .null:
          return true
        case .unknown:
          return false
      }
    } else {
      return false
    }
    return lhs.description == rhs.description
  }
}

extension Json: Swift.CustomStringConvertible {
  public var description: String {
    return descriptionPrint() ?? "unknown"
  }
}

extension Json: Swift.CustomDebugStringConvertible {
  public var debugDescription: String {
    description
  }
}

extension Json {
  
  fileprivate func descriptionPrint() -> String? {
    switch type {
      case .dictionary:
        if let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]) {
          return data.toString()
        } else {
          return rawDictionary.description
        }
        
      case .array:
        if let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]) {
          return data.toString()
        } else {
          return rawArray.description
        }
        
      case .string:
        if JSONSerialization.isValidJSONObject(rawString),
           let data = try? JSONSerialization.data(withJSONObject: rawString, options: [.prettyPrinted]) {
          return data.toString()
        } else {
          return rawString.description
        }
        
      case .number:
        return rawNumber.description
        
      case .bool:
        return rawBool.description
        
      case .null:
        return rawNull.description
        
      default:
        break
    }
    return nil
  }
}

extension Json {
  
  public func toData(options: JSONSerialization.WritingOptions = []) -> Data? {
    try? JSONSerialization.data(withJSONObject: object, options: options)
  }
  
  public func toDictionary() -> [String: Any]? {
    return toData()?.toDictionary()
  }
  
  public func asString(encoding: String.Encoding = .utf8) -> String? {
    toData()?.toString(encoding: encoding)
  }
  
  public func toModel<D>(_ type: D.Type, using decoder: JSONDecoder? = nil) -> D? where D: Decodable {
    guard let data = toData() else {
      return nil
    }
    let decoder = decoder ?? JSONDecoder()
    return try? decoder.decode(type, from: data)
  }
}

extension Json {
  
  public var number: NSNumber? {
    get {
      switch type {
        case .number: return rawNumber
        case .bool:   return NSNumber(value: rawBool ? 1 : 0)
        default:      return nil
      }
    }
    set {
      object = newValue ?? NSNull()
    }
  }
  
  public var numberValue: NSNumber {
    get {
      switch type {
        case .string:
          let decimal = NSDecimalNumber(string: object as? String)
          return decimal == .notANumber ? .zero : decimal
        case .number: return object as? NSNumber ?? NSNumber(value: 0)
        case .bool: return NSNumber(value: rawBool ? 1 : 0)
        default: return NSNumber(value: 0.0)
      }
    }
    set {
      object = newValue
    }
  }
}

extension Json {
  
  public var double: Double? {
    get {
      return number?.doubleValue
    }
    set {
      if let newValue = newValue {
        object = NSNumber(value: newValue)
      } else {
        object = NSNull()
      }
    }
  }
  
  public var doubleValue: Double {
    get {
      return numberValue.doubleValue
    }
    set {
      object = NSNumber(value: newValue)
    }
  }
  
  public var float: Float? {
    get {
      return number?.floatValue
    }
    set {
      if let newValue = newValue {
        object = NSNumber(value: newValue)
      } else {
        object = NSNull()
      }
    }
  }
  
  public var floatValue: Float {
    get {
      return numberValue.floatValue
    }
    set {
      object = NSNumber(value: newValue)
    }
  }
  
  public var int: Int? {
    get {
      return number?.intValue
    }
    set {
      if let newValue = newValue {
        object = NSNumber(value: newValue)
      } else {
        object = NSNull()
      }
    }
  }
  
  public var intValue: Int {
    get {
      return numberValue.intValue
    }
    set {
      object = NSNumber(value: newValue)
    }
  }
  
  public var uInt: UInt? {
    get {
      return number?.uintValue
    }
    set {
      if let newValue = newValue {
        object = NSNumber(value: newValue)
      } else {
        object = NSNull()
      }
    }
  }
  
  public var uIntValue: UInt {
    get {
      return numberValue.uintValue
    }
    set {
      object = NSNumber(value: newValue)
    }
  }
  
  public var int8: Int8? {
    get {
      return number?.int8Value
    }
    set {
      if let newValue = newValue {
        object = NSNumber(value: Int(newValue))
      } else {
        object =  NSNull()
      }
    }
  }
  
  public var int8Value: Int8 {
    get {
      return numberValue.int8Value
    }
    set {
      object = NSNumber(value: Int(newValue))
    }
  }
  
  public var uInt8: UInt8? {
    get {
      return number?.uint8Value
    }
    set {
      if let newValue = newValue {
        object = NSNumber(value: newValue)
      } else {
        object =  NSNull()
      }
    }
  }
  
  public var uInt8Value: UInt8 {
    get {
      return numberValue.uint8Value
    }
    set {
      object = NSNumber(value: newValue)
    }
  }
  
  public var int16: Int16? {
    get {
      return number?.int16Value
    }
    set {
      if let newValue = newValue {
        object = NSNumber(value: newValue)
      } else {
        object =  NSNull()
      }
    }
  }
  
  public var int16Value: Int16 {
    get {
      return numberValue.int16Value
    }
    set {
      object = NSNumber(value: newValue)
    }
  }
  
  public var uInt16: UInt16? {
    get {
      return number?.uint16Value
    }
    set {
      if let newValue = newValue {
        object = NSNumber(value: newValue)
      } else {
        object =  NSNull()
      }
    }
  }
  
  public var uInt16Value: UInt16 {
    get {
      return numberValue.uint16Value
    }
    set {
      object = NSNumber(value: newValue)
    }
  }
  
  public var int32: Int32? {
    get {
      return number?.int32Value
    }
    set {
      if let newValue = newValue {
        object = NSNumber(value: newValue)
      } else {
        object =  NSNull()
      }
    }
  }
  
  public var int32Value: Int32 {
    get {
      return numberValue.int32Value
    }
    set {
      object = NSNumber(value: newValue)
    }
  }
  
  public var uInt32: UInt32? {
    get {
      return number?.uint32Value
    }
    set {
      if let newValue = newValue {
        object = NSNumber(value: newValue)
      } else {
        object =  NSNull()
      }
    }
  }
  
  public var uInt32Value: UInt32 {
    get {
      return numberValue.uint32Value
    }
    set {
      object = NSNumber(value: newValue)
    }
  }
  
  public var int64: Int64? {
    get {
      return number?.int64Value
    }
    set {
      if let newValue = newValue {
        object = NSNumber(value: newValue)
      } else {
        object =  NSNull()
      }
    }
  }
  
  public var int64Value: Int64 {
    get {
      return numberValue.int64Value
    }
    set {
      object = NSNumber(value: newValue)
    }
  }
  
  public var uInt64: UInt64? {
    get {
      return number?.uint64Value
    }
    set {
      if let newValue = newValue {
        object = NSNumber(value: newValue)
      } else {
        object =  NSNull()
      }
    }
  }
  
  public var uInt64Value: UInt64 {
    get {
      return numberValue.uint64Value
    }
    set {
      object = NSNumber(value: newValue)
    }
  }
}
