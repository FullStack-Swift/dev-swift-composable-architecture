import Dependencies

public extension DependencyValues {
  var urlString: String {
    self[URLStringDependencyKey.self]
  }
}

struct URLStringDependencyKey: DependencyKey {
  static let liveValue = "http://0.0.0.0:8080"
}

public extension DependencyValues {
  var todoService: TodoService {
    self[TodoServiceDependencyKey.self]
  }
}

struct TodoServiceDependencyKey: DependencyKey {
  static let liveValue = TodoService()
}
