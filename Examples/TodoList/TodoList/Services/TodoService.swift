import Foundation

public class TodoService: BaseService {

  public override init(_ path: String? = nil) {
    super.init(path ?? "todos")
  }

  func readTodo(_ model: TodoModel?) -> MRequest {
    MRequest {
      RUrl(urlString: urlString)
        .withPath(path)
        .withPath(model?.id.toString())
      RMethod(.get)
    }
  }

  func readsTodo() -> MRequest {
    MRequest {
      RUrl(urlString: urlString)
        .withPath(path)
      RMethod(.get)
    }
  }

  func createTodo(_ model: TodoModel?) -> MRequest {
    MRequest {
      RUrl(urlString: urlString)
        .withPath(path)
      REncoding(JSONEncoding.default)
      RMethod(.post)
      Rbody(model?.toData())
    }
  }

  func updateTodo(_ model: TodoModel?) -> MRequest {
    MRequest {
      RUrl(urlString: urlString)
        .withPath(path)
        .withPath(model?.id.toString())
      RMethod(.post)
      Rbody(model?.toData())
    }
  }

  func deleteTodo(_ model: TodoModel?) -> MRequest {
    MRequest {
      RUrl(urlString: urlString)
        .withPath(path)
        .withPath(model?.id.toString())
      RMethod(.delete)
    }
  }
}
