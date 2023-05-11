import Foundation

public class TodoService: BaseService {

  func getTodos() -> MRequest {
    MRequest {
      RUrl(urlString: urlString)
      RMethod(.get)
    }
  }

  func createOrUpdateTodo(_ model: Data?) -> MRequest {
    MRequest {
      RUrl(urlString: urlString)
      REncoding(JSONEncoding.default)
      RMethod(.post)
      Rbody(model.toData())
    }
  }

  func updateTodo(_ model: TodoModel) -> MRequest {
    MRequest {
      RUrl(urlString: urlString)
        .withPath(model.id.toString())
      RMethod(.post)
      Rbody(model.toData())
    }
  }

  func deleteTodo(_ model: TodoModel) -> MRequest {
    MRequest {
      RUrl(urlString: urlString)
        .withPath(model.id.toString())
      RMethod(.delete)
    }
  }
}
