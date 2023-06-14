import Foundation

public class UserService: BaseService {

  public override init(_ path: String? = nil) {
    super.init(path ?? "users")
  }

}
