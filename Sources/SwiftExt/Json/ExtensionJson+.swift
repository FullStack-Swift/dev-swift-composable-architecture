import Foundation

public extension String {
  
  func toJson() -> Json {
    Json(parseJson: self)
  }
  
}

public extension Data {
  func toJson() -> Json {
    Json(data: toDataPrettyPrinted())
  }
}

public extension Dictionary {
  func toJson()-> Json {
    Json(self)
  }
}

public extension Encodable {
  
  func toJson() -> Json {
    Json(toData() as Any)
  }
  
}
