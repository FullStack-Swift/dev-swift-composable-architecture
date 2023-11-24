import Foundation

struct TodoModel: BaseIDModel {
  var id: UUID
  var text: String
  var isCompleted: Bool
}
