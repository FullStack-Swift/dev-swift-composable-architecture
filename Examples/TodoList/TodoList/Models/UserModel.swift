import Foundation

struct UserModel: BaseIDModel {
  var id: UUID
  var username: String
  var password: String
}
