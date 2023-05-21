import Dependencies

extension DependencyValues {
  
  private struct URLStringDependencyKey: DependencyKey {
    static let liveValue = "http://0.0.0.0:8080"
  }
  
  public var urlString: String {
    self[URLStringDependencyKey.self]
  }
}

extension DependencyValues {
  
  private struct TodoServiceDependencyKey: DependencyKey {
    static let liveValue = TodoService()
  }
  
  public var todoService: TodoService {
    self[TodoServiceDependencyKey.self]
  }
}
