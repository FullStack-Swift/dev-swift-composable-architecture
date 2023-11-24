import Fluent
import Vapor

final class Todo: Model, Content {
  static let schema = "todos"
  
  @ID(key: .id)
  var id: UUID?
  
  @Field(key: "text")
  var text: String
  
  @Field(key: "isCompleted")
  var isCompleted: Bool
  
  init() { }
  
  init(id: UUID? = nil, text: String, isCompleted: Bool) {
    self.id = id
    self.text = text
    self.isCompleted = isCompleted
  }
}

extension Todo {
  
  struct Migration: AsyncMigration {
    
    var name: String { "CreateTodo" }
    
    func prepare(on database: Database) async throws {
      try await database.schema("todos")
        .id()
        .field("text", .string, .required)
        .field("isCompleted", .bool, .required)
        .create()
    }
    
    func revert(on database: Database) async throws {
      try await database.schema("todos").delete()
    }
  }
}
