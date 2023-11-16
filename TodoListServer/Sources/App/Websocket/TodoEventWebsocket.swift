import Foundation

struct WSTodoAction: Codable {
  var action: Action
  var todo: Todo
}

extension WSTodoAction {
  enum Action: String, Codable {
    case update
    case create
    case delete
  }
}
