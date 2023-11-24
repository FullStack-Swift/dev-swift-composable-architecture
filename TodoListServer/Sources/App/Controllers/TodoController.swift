import Fluent
import Vapor
import Transform

struct TodoController: RouteCollection {
  
  func boot(routes: RoutesBuilder) throws {
    let todos = routes.grouped("todos")
    todos.get(use: index)
    todos.post(use: create)
    todos.delete(":todoID", use: delete(req:))
    todos.post(":todoID", use: update(req:))
    todos.patch(":todoID", use: update(req:))
  }
  /// read all todos
  func index(req: Request) async throws -> [Todo] {
    try await Todo.query(on: req.db).all()
  }
  
  /// paginate
  func paginate(req: Request) async throws -> Page<Todo> {
    try await Todo.query(on: req.db).paginate(for: req)
  }
  
  /// create or update the todo
  func create(req: Request) async throws -> Todo {
    let todo = try req.content.decode(Todo.self)
    try await todo.save(on: req.db)
    websocketClients.send(WSTodoAction(action: .create, todo: todo).toData().toString())
    return todo
  }
  /// update the todo
  func update(req: Request) async throws -> Todo {
    let update = try req.content.decode(Todo.self)
    guard let todo = try await Todo.find(req.parameters.get("todoID"), on: req.db) else {
      throw Abort(.notFound)
    }
    todo.isCompleted = update.isCompleted
    todo.text = update.text
    try await todo.save(on: req.db)
    websocketClients.send(WSTodoAction(action: .update, todo: todo).toData().toString())
    return todo
  }
  /// delete the todo
  func delete(req: Request) async throws -> Todo {
    guard let todo = try await Todo.find(req.parameters.get("todoID"), on: req.db) else {
      throw Abort(.notFound)
    }
    try await todo.delete(on: req.db)
    websocketClients.send(WSTodoAction(action: .delete, todo: todo).toData().toString())
    return todo
  }
}
